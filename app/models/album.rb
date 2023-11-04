# frozen_string_literal: true

class Album < ApplicationRecord
  extend FriendlyId
  friendly_id :title, use: :scoped, scope: :artist

  validates :title, presence: true
  validates :price, presence: true, numericality: true

  belongs_to :artist
  has_many :tracks, -> { order(position: :asc) }, dependent: :destroy, inverse_of: :album
  accepts_nested_attributes_for :tracks, reject_if: :all_blank
  has_many :downloads, dependent: :destroy

  has_one_attached :cover

  scope :published, -> { where(published: true) }
  scope :unpublished, -> { where(published: false) }
  scope :in_release_order, -> { order('released_at DESC NULLS LAST') }

  def preview
    first_track_with_preview = tracks.detect(&:preview)
    first_track_with_preview&.preview
  end

  def retranscode!
    tracks.each(&:transcode)
  end

  def publish
    update(published: true)

    ZipDownloadJob.perform_later(self, format: :mp3v0)
    ZipDownloadJob.perform_later(self, format: :flac)
  end

  def unpublish
    update(published: false)
  end
end
