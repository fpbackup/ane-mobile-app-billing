package {

import flash.display.Sprite;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.geom.Rectangle;

import starling.core.Starling;
import starling.utils.HAlign;
import starling.utils.VAlign;

public class Main extends Sprite {

    private var _starling:Starling;

    public function Main()
    {
        this.mouseEnabled = this.mouseChildren = false;
        this.loaderInfo.addEventListener(Event.COMPLETE, loaderInfo_completeHandler);
    }

    private function loaderInfo_completeHandler(event:Event):void
    {
        stage.align = StageAlign.TOP_LEFT;
        stage.scaleMode = StageScaleMode.NO_SCALE;
        stage.frameRate = 60;
        Starling.handleLostContext = true;
        Starling.multitouchEnabled = true;
        _starling = new Starling(TestApp, this.stage);
        _starling.enableErrorChecking = false;
        _starling.start();
        _starling.showStatsAt(HAlign.RIGHT, VAlign.BOTTOM);

        this.stage.addEventListener(Event.RESIZE, stage_resizeHandler, false, int.MAX_VALUE, true);
        this.stage.addEventListener(Event.DEACTIVATE, stage_deactivateHandler, false, 0, true);
    }

    private function stage_resizeHandler(event:Event):void
    {
        this._starling.stage.stageWidth = this.stage.stageWidth;
        this._starling.stage.stageHeight = this.stage.stageHeight;

        const viewPort:Rectangle = this._starling.viewPort;
        viewPort.width = this.stage.stageWidth;
        viewPort.height = this.stage.stageHeight;
        try
        {
            this._starling.viewPort = viewPort;
        }
        catch(error:Error) {}
    }

    private function stage_deactivateHandler(event:Event):void
    {
        this._starling.stop();
        this.stage.addEventListener(Event.ACTIVATE, stage_activateHandler, false, 0, true);
    }

    private function stage_activateHandler(event:Event):void
    {
        this.stage.removeEventListener(Event.ACTIVATE, stage_activateHandler);
        this._starling.start();
    }



}
}
