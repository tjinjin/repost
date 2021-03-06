require 'application_system_test_case'

class PostsTest < ApplicationSystemTestCase
  def setup
    super
    @user = users(:member)
    sign_in_as(@user)
    stub_request(:post, 'http://example.com')
  end

  test 'index posts' do
    11.times { |n| @user.posts.create(content: "post content #{n}") }

    visit '/'
    assert_content 'post content 10'
    assert_no_content 'post content 0'

    page.execute_script("document.getElementById('post_list_content').scrollTop = 99999")
    assert_content 'post content 0'
  end

  test 'create and update post' do
    visit '/posts/new'
    assert_current_path '/posts/new'

    click_on 'Submit'
    assert_content "Content can't be blank"

    find('.public-DraftEditor-content').set('new post content')
    click_on 'Submit'
    assert_content 'Created new post.'
    assert_content 'new post content'

    # Assert after create to set editor state
    post = Post.last
    visit "/posts/#{post.id}/edit"
    assert_current_path "/posts/#{post.id}/edit"
    assert_content 'new post content'

    find('.public-DraftEditor-content').set('updated post content')
    click_on 'Submit'
    assert_content 'Updated a post.'
    assert_content 'updated post content'
    assert_no_content 'new post content'
  end

  test 'destroy post' do
    post = @user.posts.first
    post.update content: 'new post content', created_at: Time.now

    visit '/'
    assert_content 'new post content'

    accept_alert do
      find('#delete_post').click
    end
    assert_content 'Deleted a post.'
    assert_no_content 'new post content'
  end

  test 'star post' do
    visit '/'

    find('#star_post').click
    within '.card:first-child' do
      assert_selector '.fa-star-o'
    end

    find('#star_post').click
    within '.card:first-child' do
      assert_no_selector '.fa-star-o'
    end
  end

  test 'select post' do
    visit '/'
    within '#post_content' do
      assert_content 'post content 0'
    end

    find('.card:nth-child(2)').click
    within '#post_content' do
      assert_content 'post content 1'
    end
  end

  test 'with no post' do
    Post.destroy_all
    visit '/'
    assert_current_path '/'
    assert_content 'No post found.'
  end
end
