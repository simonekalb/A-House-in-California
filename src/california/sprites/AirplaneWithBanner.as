package california.sprites {
    import org.flixel.*;
    import california.Main;
    
    public class AirplaneWithBanner extends GameSprite {
        public var glow:FlxSprite;
        private var glowOffset:FlxPoint;
        private var speed:Number;

        private var light:FlxSprite;
        
        public function AirplaneWithBanner(name:String, X:Number, Y:Number):void {
            super(name, X, Y);

            glow = new FlxSprite(X,Y, Main.library.getAsset('planeGlow'));
            glow.blend = "screen";

            glowOffset = new FlxPoint(1 - glow.width, 14 - (glow.height / 2));

            light = new FlxSprite(X,Y, Main.library.getAsset('planeGlow'));
            light.alpha = 0.1;
            
            //glow.scale.x = glow.scale.y = 2;
            
            speed = 16;
        }

        override public function update():void {
            x -= speed * FlxG.elapsed;

            var offstageOffset:Number = 40;
            if(x < -width) {
                x = FlxG.width + offstageOffset;
            }

            if(x > FlxG.width) {
                glow.alpha = 1.0 - (x - FlxG.width) / offstageOffset;
            } else {
                glow.alpha = 1.0;
            }

            glow.x = this.x + glowOffset.x;
            glow.y = this.y + glowOffset.y;            

            light.x = this.x + glowOffset.x;
            light.y = this.y + glowOffset.y;            

            
            
            super.update();
        }

        override public function render():void {
            light.render();
            super.render();
        }
    }
}