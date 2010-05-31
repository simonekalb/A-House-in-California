package california {
    import org.flixel.*;
    import california.sprites.*;
    
    public class PlayState extends FlxState {
        [Embed(source="/../data/autotiles.png")]
        private var AutoTiles:Class;

        private var roomGroup:FlxGroup;    
        private var backgroundGroup:FlxGroup;
        private var spriteGroup:FlxGroup;        
        private var hudGroup:FlxGroup;

        private var background:FlxSprite;
        private var player:Player;

        private var darkness_color:uint = 0xaa000000;
        private var darkness:FlxSprite;
        
        public static var WORLD_LIMITS:FlxPoint;

        private var world:World;
        private var currentRoom:Room;
        private var roomTitle:FlxText;
        private var cursor:GameCursor;

        public static var vocabulary:Vocabulary;
        private var currentVerb:Verb;
        public static var dialog:DialogWindow;
        public static var hasMouseFocus:Boolean = true;
        public static var instance:PlayState;
        
        override public function create():void {
            roomGroup = new FlxGroup();
            
            this.add(roomGroup);
            
            world = new World();
            WORLD_LIMITS = new FlxPoint(FlxG.width, FlxG.height);

            // Set up global vocabulary
            vocabulary = new Vocabulary();
            
            // Player
            //player = new Player(145, 135);
            player = new LoisPlayer(145, 135);
            
            // Load room
            loadRoom('home');

            currentVerb = vocabulary.verbData['Walk'];
            
            hudGroup = new FlxGroup();
            hudGroup.add(vocabulary.currentVerbs);
            this.add(hudGroup);
            
            cursor = new GameCursor();
            this.add(cursor);

            dialog = new DialogWindow();
            this.add(dialog);

            instance = this;
        }

        override public function update():void {
            var verb:Verb; // used to iterate thru verbs below in a few places

            if(PlayState.hasMouseFocus) {
                if(FlxG.mouse.y > 146) {
                    // UI area mouse behavior
                    cursor.setText(null);

                    for each (verb in vocabulary.currentVerbs.members) {
                        verb.highlight = false;
                    }
                    for each (verb in vocabulary.currentVerbs.members) {
                        if(cursor.graphic.overlaps(verb)) {
                            verb.highlight = true;
                            if(FlxG.mouse.justPressed()) {
                                currentVerb = verb;
                            }

                            break;
                        }
                    }
                } else {
                    // Game area mouse behavior
                    
                    for each (verb in vocabulary.currentVerbs.members) {
                        if(verb == currentVerb) {
                            verb.highlight = true;
                        } else {
                            verb.highlight = false;
                        }
                    }

                    var cursorOverlappedSprite:Boolean = false;

                    for each(var sprite:GameSprite in currentRoom.sprites.members) {
                        if(cursor.spriteHitBox.overlaps(sprite)) {
                            cursor.setText(sprite.getVerbText(currentVerb));
                            cursorOverlappedSprite = true;

                            if(FlxG.mouse.justPressed()) {
                                FlxG.log('attempting to handle verb ' + currentVerb + ' with sprite ' + sprite);
                                sprite.handleVerb(currentVerb);
                            }
                        }
                    }

                    if(!cursorOverlappedSprite) {
                        cursor.setText(currentVerb.name);                    
                    }

                    if(FlxG.mouse.justPressed()) {
                        if(currentVerb.name == 'Walk') {
                            player.setWalkTarget(FlxG.mouse.x);
                        }
                    }
                }
            }
            super.update();
        }

        static public function transitionToRoom(roomName:String):void {
            var fadeDuration:Number = 0.5;
            
            PlayState.hasMouseFocus = false;
            
            FlxG.fade.start(0xff000000, fadeDuration, function():void {
                    FlxG.fade.stop();
                    instance.loadRoom(roomName);
                    FlxG.flash.start(0xff000000, fadeDuration, function():void {
                            PlayState.hasMouseFocus = true;
                            FlxG.flash.stop();
                        });
                });
        }
        
        private function loadRoom(roomName:String):void {
            this.roomGroup.destroy();
            
            currentRoom = world.getRoom(roomName);
            backgroundGroup = currentRoom.backgrounds;
            spriteGroup = currentRoom.sprites;
            
            player = new LoisPlayer(145, 135);            
            spriteGroup.add(player);
            
            this.roomGroup.add(backgroundGroup);
            this.roomGroup.add(spriteGroup);            

            roomTitle = new FlxText(8, 8, FlxG.width, currentRoom.title);
            roomTitle.setFormat(null, 8, 0xffffffff);
            this.roomGroup.add(roomTitle);

            FlxG.log('finished loading room ' + roomName);
       }
    }
}