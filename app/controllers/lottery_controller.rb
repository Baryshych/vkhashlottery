class LotteryController < ApplicationController

  def initialize
    @users = []
    @posts = []
  end

  def index

  end

  def find
    get_data
    render 'lottery/find'
  end

  def reroll
    choose_winner(@posts, @users)
    redirect_back
  end

  def get_data
    vk = VkontakteApi::Client.new
    options = {
        q: params[:q],
        count: 200,
        extended: 1,
        offset: 0,
        v: 5.12
    }
    begin
      posts = vk.newsfeed.search(options)
      users = posts[:profiles]
      @posts += posts['items'].select do |post|
        post.post_type == 'post' && posts['profiles'].find{|user| user.id = post.owner_id}
      end
      @users += users
      options[:offset] += 200
    end while posts[:items].count >= 200
    # updating cache #

    if @users.count > 0
      posts = @posts.map do |post|
        post = {'owner_id' => post['owner_id']}.to_json
      end
      users = @users.map do |user|
        user = {'id' => user['id'], 'first_name' => user['first_name'], 'last_name' => user['last_name'], 'screen_name' => user['screen_name'], 'photo_100' => user['photo_100']}.to_json
      end
      $REDIS.del('users')
      $REDIS.lpush('users', users)
      $REDIS.del('posts')
      $REDIS.lpush('posts', posts)
    end
    choose_winner(@posts, @users)
  end

  def choose_winner(posts, users)
    # if (!users)
    posts = $REDIS.lrange('posts', 0, -1).map do |post|
      post = JSON.parse post
    end
    @users = $REDIS.lrange('users', 0, -1).map do |user|
      user = JSON.parse user
    end
    # end
    while @winner == nil
      @post = posts.sample
      @winner = @users.find { |user| user['id'] == @post['owner_id'] }
    end
  end

end
