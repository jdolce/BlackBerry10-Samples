package qnx.samples.mediaplayer
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	public class FeedParser extends EventDispatcher
	{
		
		private var __items:Array;
		
		public function get items():Array
		{
			return( __items );
		}
		
		public function FeedParser()
		{
			
		}

		public function loadFeed( url:String ):void
		{
			var loader:URLLoader = new URLLoader();
			loader.addEventListener( Event.COMPLETE, loaded );
			loader.load( new URLRequest( url ) );
		}
		
		private function loaded( e:Event ):void
		{
			var loader:URLLoader = e.target as URLLoader;
			var data:String = String( loader.data );
			
			var xml:XML = new XML( data );
			var items:XMLList = xml.channel.item;
			
			__items = [];
			
			for( var i:int = 0; i<items.length(); i++ )
			{
				var item:XML = items[ i ] as XML;
				
				var videoItem:VideoItem = new VideoItem();
				
				videoItem.title = item.title.toString();
				videoItem.description = item.description.toString();
				videoItem.url = item.enclosure.@url;
				videoItem.length = item.enclosure.@length;
				videoItem.pubDate = item.pubDate.toString();
				var media:Namespace = new Namespace("http://search.yahoo.com/mrss/");

				videoItem.thumbnail = item.media::thumbnail.@url;
				videoItem.thumbnailw = int( item.media::thumbnail.@width );
				videoItem.thumbnailh = int( item.media::thumbnail.@height );
				
				__items.push( videoItem );
				
			}
			
			dispatchEvent( new Event( Event.COMPLETE ) );
		}
	}
}