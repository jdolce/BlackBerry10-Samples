package qnx.samples.mediaplayer
{
	import qnx.fuse.ui.events.ListEvent;
	import qnx.fuse.ui.listClasses.List;
	import qnx.ui.data.DataProvider;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	

	
	public class TEDTalks extends Sprite
	{
		
		private var items:Array;
		private var list:List;
		private var player:VideoPlayer;
		private var bg:Bitmap;
		
		public function TEDTalks()
		{
			//http://feeds.feedburner.com/TedtalksHD?format=xml
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			var bd:BitmapData = new BitmapData( stage.stageWidth, stage.stageHeight, false, 0xFFFAFAFA );
			bg = new Bitmap( bd );		
			addChild( bg );

			var parser:FeedParser = new FeedParser();
			parser.addEventListener( Event.COMPLETE, feedLoaded );
			parser.loadFeed( "http://feeds.feedburner.com/TedtalksHD?format=xml" );
		}

		private function feedLoaded( e:Event ):void
		{
			trace( "feedLoaded" );
			var parser:FeedParser = FeedParser( e.target );
			items = parser.items;
			
			list = new List();
			list.width = stage.stageWidth;
			list.height = stage.stageHeight;
			list.cellRenderer = VideoListCellRenderer;
			list.dataProvider = new DataProvider( items );
			list.addEventListener(ListEvent.ITEM_CLICKED, itemClicked );
			addChild( list );
			
			player = new VideoPlayer();
			player.width = stage.stageWidth;
			player.height = stage.stageHeight;
			player.addEventListener( Event.CLOSE, onPlayerClosed );
			addChild( player );
			player.visible = false;
			
			
		}
		
		protected function onPlayerClosed(event:Event):void
		{
			player.visible = false;
			list.visible = true;
			bg.visible = true;
		}
		
		protected function itemClicked(event:ListEvent):void
		{
			var data:VideoItem = event.data as VideoItem;
			player.visible = true;
			player.playVideo( data );
			list.visible = false;
			bg.visible = false;
		}
	}
}