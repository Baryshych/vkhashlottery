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
      @posts += posts['items']
      @users += users
      options[:offset] += 200
    end while posts[:items].count >= 200
    choose_winner(@posts, @users)
  end

  def choose_winner(posts, users)
    @post = posts.sample
    @winner = users.select{|user| user['id'] == @post.owner_id}
  end

end
