program GameMain;
uses SwinGame, sgTypes;

type
  BuggyGameData = record
    buggy: Sprite;
  end;

procedure LoadResources();
begin
  LoadResourceBundleNamed('bugsplat', 'BugSplat.txt', false);
end;

procedure PlaceBuggy(s: Sprite);
begin
  // Place either top/bottom 50% or left/right 50%
  if Rnd(2) = 0 then // place top/bottom
  begin
    if Rnd(2) = 0 then // top
      SpriteSetY(s, -SpriteHeight(s))
    else
      SpriteSetY(s, ScreenHeight());

    SpriteSetX(s, Rnd(ScreenWidth()));
  end
  else // place left/right
  begin
    if Rnd(2) = 0 then // top
      SpriteSetX(s, -SpriteWidth(s))
    else
      SpriteSetX(s, ScreenWidth());

    SpriteSetY(s, Rnd(ScreenHeight()));    
  end;

  // Move toward a random screen point
  SpriteSetVelocity(s, VectorMultiply(UnitVector(VectorFromPoints(CenterPoint(s), RandomScreenPoint())), 2));
  SpriteStartAnimation(s, 'fly');
end;

procedure SetupGameData(var game: BuggyGameData);
begin
  game.buggy := CreateSprite(BitmapNamed('Buggy'), AnimationScriptNamed('BuggyAnimations'));

  PlaceBuggy(game.buggy);
end;

procedure KeepOnScreen(s: Sprite);
begin
  if (SpriteX(s) < -SpriteWidth(s)) or (SpriteX(s) > ScreenWidth()) then // off left or right
  begin
    SpriteSetDX(s, -SpriteDX(s));
  end;

  if (SpriteY(s) < -SpriteHeight(s)) or (SpriteY(s) > ScreenHeight()) then // off top or bottom
  begin
    SpriteSetDY(s, -SpriteDY(s));
  end;
end;

procedure HandleInput(var game: BuggyGameData);
var
  pt: Point2D;
begin
  if MouseClicked(LeftButton) then
  begin
    if SpriteRectCollision(game.buggy, MouseX() - 10, MouseY() - 10, 20, 20) then
    begin
      SpriteStartAnimation(game.buggy, 'splat');
    end
    else PlaySoundEffect('Hit');
  end;
end;

procedure UpdateGame(var game: BuggyGameData);
begin
  UpdateSprite(game.buggy);
  KeepOnScreen(game.buggy);

  if SpriteAnimationHasEnded(game.buggy) then
  begin
    PlaceBuggy(game.buggy);
  end;
end;

procedure DrawGame(const game: BuggyGameData);
begin
  DrawSprite(game.buggy);
end;


procedure Main();
var
  game: BuggyGameData;
begin
  OpenAudio();
  
  OpenGraphicsWindow('Bug Splat', 1024, 768);
  LoadDefaultColors();
  // ShowSwinGameSplashScreen();

  LoadResources();
  SetupGameData(game);
  
  repeat // The game loop...
    ProcessEvents();
    HandleInput(game);

    UpdateGame(game);

    ClearScreen(ColorWhite);
    DrawGame(game);
    DrawFramerate(0,0);
    
    RefreshScreen(60);
  until WindowCloseRequested();
  
  CloseAudio();
  ReleaseAllResources();
end;

begin
  Main();
end.
