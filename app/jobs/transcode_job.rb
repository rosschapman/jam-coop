# frozen_string_literal: true

class TranscodeJob < ApplicationJob
  queue_as :default

  def perform(track)
    output_fn = "#{track.original.filename.base}.mp3"

    Tempfile.create('transcode') do |output|
      track.original.open { |file| transcode(file, output) }
      track.transcodes.where(format: :mp3v0).destroy_all
      transcode = track.transcodes.create(format: :mp3v0)
      transcode.file.attach(io: File.open(output.path), filename: output_fn, content_type: 'audio/mpeg')
    end
  end

  private

  def transcode(input, output)
    cmd = "ffmpeg -y -nostats -loglevel 0 -i #{input.path} -codec:a libmp3lame -q:a 0 -f mp3 #{output.path}"
    system(cmd)
  end
end