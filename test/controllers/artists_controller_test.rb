# frozen_string_literal: true

require 'test_helper'

class ArtistsControllerTestSignedIn < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user, admin: true)
    log_in_as(@user)
    @artist = create(:artist)
  end

  test '#index' do
    get artists_url
    assert_response :success
  end

  test '#index should show both listed and unlisted artist' do
    get artists_url
    assert_select 'p', "#{@artist.name} (unlisted)"

    @artist.albums << create(:album, publication_status: :published)

    get artists_url
    assert_select 'p', @artist.name
  end

  test '#show should include published albums' do
    @artist.albums << create(:album, title: 'Album Title', publication_status: :published)

    get artist_url(@artist)

    assert_select 'p', 'Album Title'
  end

  test '#show should include unpublished albums' do
    @artist.albums << create(:album, title: 'Album Title', publication_status: :unpublished)

    get artist_url(@artist)

    assert_select 'p', 'Album Title (unpublished)'
  end

  test '#show should include pending albums' do
    @artist.albums << create(:album, title: 'Album Title', publication_status: :pending)

    get artist_url(@artist)

    assert_select 'p', 'Album Title (pending)'
  end

  test '#new' do
    get new_artist_url
    assert_response :success
  end

  test '#create' do
    assert_difference('Artist.count') do
      post artists_url, params: { artist: { name: 'Example' } }
    end

    assert_redirected_to artist_url(Artist.last)
  end

  test '#create associates the new artist with the current user' do
    post artists_url, params: { artist: { name: 'Example' } }

    assert_equal @user, Artist.last.user

    assert_redirected_to artist_url(Artist.last)
  end

  test '#edit' do
    get edit_artist_url(@artist)
    assert_response :success
  end

  test '#update' do
    patch artist_url(@artist), params: { artist: { name: 'New name' } }
    assert_redirected_to artist_url(@artist)
  end

  test '#destroy' do
    assert_difference('Artist.count', -1) do
      delete artist_url(@artist)
    end

    assert_redirected_to artists_url
  end
end

class ArtistsControllerTestSignedInArtist < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user)
    @artist = create(:artist)
    @user.artists << @artist

    log_in_as(@user)
  end

  test '#show should include published albums' do
    @artist.albums << create(:album, title: 'Album Title', publication_status: :published)

    get artist_url(@artist)

    assert_select 'p', 'Album Title'
  end

  test '#show should include unpublished albums' do
    @artist.albums << create(:album, title: 'Album Title', publication_status: :unpublished)

    get artist_url(@artist)

    assert_select 'p', 'Album Title (unpublished)'
  end

  test '#show should include pending albums' do
    @artist.albums << create(:album, title: 'Album Title', publication_status: :pending)

    get artist_url(@artist)

    assert_select 'p', 'Album Title (pending)'
  end
end

class ArtistsControllerTestSignedOut < ActionDispatch::IntegrationTest
  setup do
    @artist = create(:artist)
  end

  test '#index' do
    get artists_url
    assert_response :success
  end

  test '#index should only show listed artists' do
    get artists_url
    assert_select 'p', { count: 0, text: @artist.name }

    @artist.albums << create(:album, publication_status: :published)

    get artists_url
    assert_select 'p', { text: @artist.name }
  end

  test '#show should include published albums' do
    @artist.albums << create(:album, title: 'Album Title', publication_status: :published)

    get artist_url(@artist)

    assert_select 'p', 'Album Title'
  end

  test '#show should not include unpublished albums' do
    @artist.albums << create(:album, title: 'Album Title', publication_status: :unpublished)

    get artist_url(@artist)

    assert_select 'p', { text: 'Album Title (unpublished)', count: 0 }
  end

  test '#show should not include pending albums' do
    @artist.albums << create(:album, title: 'Album Title', publication_status: :pending)

    get artist_url(@artist)

    assert_select 'p', { text: 'Album Title (pending)', count: 0 }
  end

  test '#new' do
    get new_artist_url
    assert_redirected_to log_in_path
  end

  test '#create' do
    post artists_url, params: { artist: { name: 'Example' } }
    assert_redirected_to log_in_path
  end

  test '#edit' do
    get edit_artist_url(@artist)
    assert_redirected_to log_in_path
  end

  test '#update' do
    patch artist_url(@artist), params: { artist: { name: 'New name' } }
    assert_redirected_to log_in_path
  end

  test '#destroy' do
    delete artist_url(@artist)

    assert_redirected_to log_in_path
  end
end
