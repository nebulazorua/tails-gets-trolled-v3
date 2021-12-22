//by smokey555
package;

import flixel.FlxG;
import openfl.display.BitmapData;
import openfl.display3D.Context3DTextureFormat;
import openfl.display3D.textures.Texture;
import openfl.utils.Assets;

using StringTools;

class GPUFunctions
{
	static var trackedTextures:Array<TexAsset> = new Array<TexAsset>();

	/**
	 * This function loads a bitmap and transfers it to the GPU's VRAM.
	 *
	 * @param   path
	 * @param   texFormat          
	 * @param   optimizeForRender 
	 * @param   _cachekey           
	 *
	 */
	public static function bitmapToGPU(path:String, texFormat:Context3DTextureFormat = BGRA, optimizeForRender:Bool = true, ?_cacheKey:String):BitmapData
	{
		if (_cacheKey == null)
			_cacheKey = path;

		for (tex in trackedTextures)
		{
			if (tex.cacheKey == _cacheKey)
				return BitmapData.fromTexture(tex.texture);
		}
		var _bmp = Assets.getBitmapData(path, false);
		var _texture = FlxG.stage.context3D.createTexture(_bmp.width, _bmp.height, texFormat, optimizeForRender);
		_texture.uploadFromBitmapData(_bmp);

		_bmp.dispose();
		_bmp.disposeImage();
		_bmp = null;

		var trackedTex = new TexAsset(_texture, _cacheKey);
		trackedTextures.push(trackedTex);

		return BitmapData.fromTexture(_texture);
	}


	public static function disposeAllTextures():Void
	{
		for (texture in trackedTextures)
		{
			texture.texture.dispose();
			trackedTextures.remove(texture);
		}

	}
}

class TexAsset
{
	public var texture:Texture;
	public var cacheKey:String;

	public function new(texture:Texture, cacheKey:String)
	{
		this.texture = texture;
		this.cacheKey = cacheKey;
	}
}
