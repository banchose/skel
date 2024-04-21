# sourcing

UserAgent='Mozilla/5.0 (iPhone; CPU iPhone OS 12_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/12.0 Mobile/15E148 Safari/604.1'

TestLink='https://www.youtube.com/watch?v=_7dfFtAPVHE'

VidDir=~/y/youtube-down/

yta() {
	(
		cd "$VidDir" || {
			echo "missing $VidDir"
			return 1
		}
		yt-dlp --user-agent "$UserAgent" --ignore-errors --format bestaudio --extract-audio --output "%(title)s.%(ext)s" "$1"
	)
}

ytam() {
	(
		cd "$VidDir" || {
			echo "missing $VidDir"
			return 1
		}
		yt-dlp --user-agent "$UserAgent" --ignore-errors --format bestaudio --extract-audio --audio-format mp3 --output "%(title)s.%(ext)s" "$1"
	)
}

ytv() {
	(
		cd "$VidDir" || {
			echo "missing $VidDir"
			return 1
		}
		yt-dlp --live-from-start --max-downloads 5 --no-playlist --user-agent 'Mozilla/5.0 (iPhone; CPU iPhone OS 12_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/12.0 Mobile/15E148 Safari/604.1' --format 'bestvideo+bestaudio/best' "$1"
	)
}

ytv-pl() {
	(
		cd "$VidDir" || {
			echo "missing $VidDir"
			return 1
		}
		yt-dlp --yes-playlist --live-from-start --max-downloads 5  --user-agent 'Mozilla/5.0 (iPhone; CPU iPhone OS 12_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/12.0 Mobile/15E148 Safari/604.1' --format 'bestvideo+bestaudio/best' "$1"
	)
}
