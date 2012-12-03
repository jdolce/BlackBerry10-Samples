package qnx.samples.mediaplayer
{
	import qnx.fuse.ui.listClasses.CellRenderer;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.net.URLRequest;
	
	public class VideoListCellRenderer extends CellRenderer
	{
		private var thumbnail:Bitmap;
		private var loader:Loader;

		public function VideoListCellRenderer()
		{
			super();
		}
		
		override protected function init():void
		{
			mouseChildren = false;
			opaqueBackground = 0xFAFAFA;
			super.init();
			paddingLeft = 121;
		}
		
		override public function set data( value:Object ):void
		{
			super.data = value;
			
			removeThumbnail();
			cancelLoading();
			
			
			if( value != null )
			{
				var item:VideoItem = value as VideoItem;
				setLabel( item.title );
				
				if( item.thumbnail != null )
				{
					var bitmapData:BitmapData = ThumbnailCache.getChache().getImage( item.thumbnail, false );
					
					if( loader == null && bitmapData == null )
					{
						loader = new Loader();
						loader.contentLoaderInfo.addEventListener(Event.COMPLETE, thumbnailLoaded );
						loader.load( new URLRequest( item.thumbnail ) );
					}
					
					if( bitmapData )
					{
						setupBitmap( new Bitmap( bitmapData ) );
					}
				}
				
			}
		}
		
		private function thumbnailLoaded( e:Event ):void
		{
			loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, thumbnailLoaded );
			
			var image:Bitmap = loader.content as Bitmap;
			
			ThumbnailCache.getChache().addImageData( data.thumbnail, image.bitmapData );
			
			setupBitmap( image );
			
			loader = null;
		}
		
		private function setupBitmap( bitmap:Bitmap ):void
		{
			thumbnail = bitmap;
			thumbnail.width = height;
			thumbnail.height = height;
			addChildAt( thumbnail, 1 );
		}
		
		private function removeThumbnail():void
		{
			if( thumbnail != null )
			{
				if( contains( thumbnail ) )
				{
					removeChild( thumbnail );
					thumbnail = null;
				}
			}
		}
		
		private function cancelLoading():void
		{
			if( loader != null )
			{
				loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, thumbnailLoaded );
				try
				{
					loader.close();
				}
				catch( e:Error )
				{
				}
				loader = null;
			}
		}
		
	}
}