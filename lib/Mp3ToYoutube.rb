require 'yt'
require 'thor'


module Mp3ToYoutube
  class Mp3Uploader < Thor
    desc "upload MP3 IMG", "upload "
    def upload mp3, img = false
      mp3_path = File.absolute_path mp3
      if File.exist? mp3_path
        audioInfo = generate_audio_info(mp3_path)
        video_background = generate_video_background(audioInfo)
        video_file = generate_video_file(mp3_path, video_background)
        upload_video_to_youtube(video_file , audioInfo)
        delete_created_files(audioInfo, video_background, video_file)
      else
        raise "mp3 file not found"
      end
    end

    # extract the title and the Artist from the MP3 and save to a .txt
    def generate_audio_info mp3
      audioInfo = File.basename(mp3, File.extname(mp3)) + ".txt"
      puts "hey "+ File.absolute_path(audioInfo)
        puts "generating Audio info #{audioInfo}"
        if !system("mediainfo --Inform='General;%Title% - %Artist% ' #{mp3} >> #{audioInfo}")
          raise "generating audio info #{audioInfo} failed"
        end
      return audioInfo
    end


    #add the proper Artist and title to the background img color
    def generate_video_background audioInfo
      video_background = File.basename(audioInfo, File.extname(audioInfo)) + ".jpg"
      puts "generating coverart of the video "
      if !system("convert -gravity Center -size 1200x720 -background '#87CEFA' -fill black -font Arial -pointsize 60 pango:@#{audioInfo}  #{video_background}")
        raise "generating convertArt #{video_background} failed"
      end
      return video_background
    end


    def generate_video_file mp3, video_background
      video_file= File.basename(video_background, File.extname(video_background)) + ".avi"
      puts "generating videofile #{video_file} "
      if !system( "ffmpeg", "-loop", "1", "-r", "2", "-i", "#{video_background}", "-i", "#{mp3}", "-vf", "scale=-1:1080", "-c:v", "libx264", "-preset", "slow", "-tune", "stillimage", "-crf", "18", "-c:a", "copy", "-shortest", "-pix_fmt", "yuv420p", "-threads", "0", "#{video_file}")
        raise "generating videofile #{video_file} from #{mp3} and #{video_background} failed"
      end
      return video_file
    end


    def upload_video_to_youtube video_file , audioInfo
      puts "Uploading the video to Youtube"
      video_title =  `mediainfo --Inform='General;%Title% - %Artist%' #{audioInfo}`.delete! "\n"
      video_description = `mediainfo --Inform='General;%Album% - %Artist%' #{audioInfo}`.delete! "\n"
      # connecting to youtube api
      Yt.configure do |config|
        config.client_id = "your client ID"
        config.client_secret = "Your Client Secret"
        config.log_level = :debug
      end
      # pushing the video to youtube with the proper title and description
      @account = Yt::Account.new refresh_token: "Your refresh token"
      @account.upload_video(video_file, privacy_status: 'public', title:  video_title, 
                            description:  video_description)
      puts "Video is uploaded successfully"
    end
  

    def delete_created_files audioInfo, video_background, video_file
      File.delete(audioInfo.to_s)
      File.delete(video_background.to_s)
      File.delete(video_file.to_s)
    end

  end
end
