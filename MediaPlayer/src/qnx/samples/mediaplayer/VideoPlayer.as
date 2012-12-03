package qnx.samples.mediaplayer
{
	import qnx.fuse.ui.events.ActionEvent;
	import qnx.events.MediaPlayerEvent;
	import qnx.events.MediaServiceConnectionEvent;
	import qnx.events.MediaServiceRequestEvent;
	import qnx.fuse.ui.actionbar.ActionBar;
	import qnx.fuse.ui.core.Action;
	import qnx.fuse.ui.core.UIComponent;
	import qnx.fuse.ui.events.MediaControlEvent;
	import qnx.fuse.ui.media.MediaControl;
	import qnx.fuse.ui.media.MediaControlOption;
	import qnx.fuse.ui.media.MediaControlProperty;
	import qnx.fuse.ui.media.MediaControlState;
	import qnx.fuse.ui.media.VideoDisplay;
	import qnx.media.MediaPlayer;
	import qnx.media.MediaPlayerMetadata;
	import qnx.media.MediaPlayerState;
	import qnx.media.MediaServiceConnection;

	import flash.events.Event;
	
	public class VideoPlayer extends UIComponent
	{
		private var video:VideoDisplay;
		private var player:MediaPlayer;
		private var control:MediaControl;
		
		private var mediaService:MediaServiceConnection;
		private var data:VideoItem;
		
		private var metaData:Object;
		private var actionBar:ActionBar;
		
		public function VideoPlayer()
		{
		}

		
		override protected function init():void
		{
			super.init();
			video = new VideoDisplay( true );
			video.backgroundColor = 0x000000;

			
			player = new MediaPlayer( null, video  );
			player.addEventListener( MediaPlayerEvent.INFO_CHANGE, mediaInfoChanged );
			player.addEventListener( MediaPlayerEvent.PREPARE_COMPLETE, prepareComplete );
			
			addChild( video );
			
			actionBar = new ActionBar();
			actionBar.backButton = new Action( "Back" );
			actionBar.addEventListener(ActionEvent.ACTION_SELECTED, onActionSelected );
			addChild( actionBar );
			
			
			control = new MediaControl();
			control.setOption(MediaControlOption.BACKGROUND, false);
			control.setOption(MediaControlOption.PLAY_PAUSE, true);
			control.setOption(MediaControlOption.SEEKBAR, true);
			control.setOption(MediaControlOption.DURATION, true);
			control.setOption(MediaControlOption.POSITION, true);
			

			control.addEventListener( MediaControlEvent.STATE_CHANGE, controlStateChange );
			control.addEventListener( MediaControlEvent.PROPERTY_CHANGE, propertyChange );
			
			addChild( control );
			
			mediaService = new MediaServiceConnection();
			mediaService.addEventListener( MediaServiceConnectionEvent.ACCESS_CHANGE, mediaServiceAccessChange );
			mediaService.addEventListener( MediaServiceRequestEvent.TRACK_PLAY, trackPlay );
			mediaService.addEventListener( MediaServiceRequestEvent.TRACK_PAUSE, trackPause );
			mediaService.connect();
			
			
			
		}

		private function onActionSelected( event:ActionEvent ):void
		{
			player.stop();
			player.reset();
			dispatchEvent( new Event( Event.CLOSE ) );
		}
		
		
		override protected function updateDisplayList( unscaledWidth:Number, unscaledHeight:Number ):void
		{
			super.updateDisplayList( unscaledWidth, unscaledHeight );
			
			
			actionBar.width = unscaledWidth;
			actionBar.y = unscaledHeight - actionBar.height;
			
			control.x = 174;
			
			video.width = unscaledWidth;
			video.height = actionBar.y;
			control.width = unscaledWidth - control.x;
			control.y = Math.round( ( actionBar.height - control.height ) / 2 ) + actionBar.y;
		}
		
		protected function trackPause(event:MediaServiceRequestEvent):void
		{
			trace( "should pause" );
			player.pause();
			control.setState(MediaControlState.PAUSE);
			mediaService.setPlayState( MediaPlayerState.PAUSED);
		}
		
		protected function trackPlay(event:MediaServiceRequestEvent):void
		{
			trace( "trackPlay" );
			player.play();
			control.setState(MediaControlState.PLAY);
			mediaService.setPlayState( MediaPlayerState.PLAYING);
		}
		
		protected function mediaServiceAccessChange(event:MediaServiceConnectionEvent):void
		{
			trace( event );
			startPlayingVideo();
		}
		
		public function playVideo( item:VideoItem ):void
		{
			metaData = {};
			metaData.artist = "TED Talks";
			metaData.track = item.title;
			metaData.albumArtwork = item.thumbnail;
			metaData.position = 0;
			metaData.duration = 0;
			
			trace( "has media service", mediaService.hasAudioService() );
			player.url = item.url;
			data = item;
			
			if( !mediaService.hasAudioService() )
			{
				mediaService.requestAudioService();
			}
			else
			{
				startPlayingVideo();
			}
			
			
			
		}
		
		private function propertyChange( event:MediaControlEvent ):void
		{
			var prop:String = event.property;
			
			trace( "property change", prop );
			switch( prop )
			{
				case MediaControlProperty.POSITION:
					player.seek( uint( control.getProperty(prop) ) );
					break;
			}
		}
		
		private function controlStateChange( event:MediaControlEvent ):void
		{
			var state:String = event.property;
			switch( state )
			{
				case MediaControlState.PLAY:
					
					var hasAccess:Boolean = mediaService.hasAudioService();
					if( hasAccess )
					{
						player.play();
						mediaService.setPlayState( MediaPlayerState.PLAYING);
					}
					else
					{
						mediaService.requestAudioService();
					}

					break;
				case MediaControlState.PAUSE:
					player.pause();
					mediaService.setPlayState( MediaPlayerState.PAUSED);
					break;
				case MediaControlState.SEEK_START:
					player.pause();
					break;
				case MediaControlState.SEEK_END:
					player.play();
					break;
			}
		}
		
		private function startPlayingVideo():void
		{
			var hasAccess:Boolean = mediaService.hasAudioService();
			
			if( hasAccess )
			{
				player.play();
				control.setState(MediaControlState.PLAY);
			}
			else
			{
				control.setState(MediaControlState.PAUSE);
				player.pause();
			}
			
		}
		
		protected function prepareComplete(event:MediaPlayerEvent):void
		{
			startPlayingVideo();
		}
		
		protected function mediaInfoChanged(event:MediaPlayerEvent):void
		{
			for( var prop:String in event.what )
			{
				//trace( prop, "=", event.what[ prop ] );
				switch( prop )
				{
					case MediaPlayerMetadata.DURATION:
						control.setProperty(MediaControlProperty.DURATION, player.duration );
						metaData.duration = player.duration;
						mediaService.sendMetadata( metaData );
						break;
					case "position":
						control.setProperty(MediaControlProperty.POSITION, player.position );
						metaData.position = player.position;
						mediaService.sendMetadata( metaData );
						break;
					case "state":
						trace( "state changed", player.isPlaying, player.isPaused );
						if( player.isPlaying )
						{
							control.setState(MediaControlState.PLAY);
							mediaService.setPlayState( MediaPlayerState.PLAYING );
						}
						else
						{
							control.setState(MediaControlState.PAUSE);
							mediaService.setPlayState( MediaPlayerState.PAUSED);
						}
				}
			}
		}
	}
}