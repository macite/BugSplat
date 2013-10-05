program GameMain;
uses SwinGame, sgTypes;

type
  BuggyGameData = record
    bugs: array of Sprite;
  end;

procedure LoadResources();
begin
  LoadResourceBundleNamed('bugsplat', 'BugSplat.txt', false);
end;

procedure PlaceBuggy(s: Sprite);
var
  target: Point2D;
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
  target := PointAt(ScreenWidth() * 0.1 + Rnd(Round(ScreenWidth() * 0.8)), ScreenHeight() * 0.1 + Rnd(Round(ScreenHeight() * 0.8)));
  SpriteSetVelocity(s, VectorMultiply(UnitVector(VectorFromPoints(CenterPoint(s), target)), 2));
  SpriteStartAnimation(s, 'fly');
  SpriteSetValue(s, 'Alive', 1);
  SpriteSetValue(s, 'Gone', 0);
end;

procedure CreateBug(var buggy: Sprite);
begin
  buggy := CreateSprite(BitmapNamed('Buggy'), AnimationScriptNamed('BuggyAnimations'));
  SpriteAddValue(buggy, 'Alive', 1);
  SpriteAddValue(buggy, 'Gone', 0);
  PlaceBuggy(buggy);
end;

procedure SetupGameData(var game: BuggyGameData);
begin
  SetLength(game.bugs, 1);
  CreateBug(game.bugs[0]);
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

procedure CheckHitBug(var game: BuggyGameData);
var
  i: Integer;
begin
  for i := 0 to High(game.bugs) do
  begin
    if (SpriteValue(game.bugs[i], 'Alive') = 1) and SpriteRectCollision(game.bugs[i], MouseX() - 20, MouseY() - 20, 40, 40) then
    begin
      SpriteStartAnimation(game.bugs[i], 'splat');
      SpriteSetValue(game.bugs[i], 'Alive', 0);
      exit;
    end;
  end;

  PlaySoundEffect('Hit');
end;

procedure HandleInput(var game: BuggyGameData);
begin
  if MouseClicked(LeftButton) then
  begin
    CheckHitBug(game);
  end;
end;

procedure BounceBugs(var bugs: array of Sprite);
var
  i, j: Integer;
begin
  for i := 0 to High(bugs) do
  begin
    if SpriteValue(bugs[i], 'Alive') = 1 then
    begin
      for j := i + 1 to High(bugs) do
      begin
        if (SpriteValue(bugs[j], 'Alive') = 1) and SpriteCollision(bugs[i], bugs[j]) then 
          CollideCircles(bugs[i], bugs[j]);
      end;
    end;
  end;
end;

procedure UpdateGame(var game: BuggyGameData);
var
  i, alive: Integer;
  currentBug: Sprite;
begin
  alive := 0;

  for i := 0 to High(game.bugs) do
  begin
    currentBug := game.bugs[i];

    UpdateSprite(currentBug);
    KeepOnScreen(currentBug);

    if SpriteValue(currentBug, 'Gone') = 0 then
    begin
      if SpriteValue(currentBug, 'Alive') = 0 then
      begin
        SpriteSetVelocity(currentBug, VectorMultiply(SpriteVelocity(game.bugs[i]), 0.98));

        if SpriteAnimationHasEnded(game.bugs[i]) then
        begin
          SpriteSetValue(currentBug, 'Gone', 1);
        end;
      end;

      alive += 1;
    end; 
  end;

  if alive = 0 then
  begin
    for i := 0 to High(game.bugs) do
    begin
      PlaceBuggy(game.bugs[i]);
    end;

    SetLength(game.bugs, Length(game.bugs) + 1);
    CreateBug(game.bugs[High(game.bugs)]);
  end;

  // BounceBugs(game.bugs);
end;

procedure DrawGame(const game: BuggyGameData);
var
  i: Integer;
begin
  for i := 0 to High(game.bugs) do
  begin
    DrawSprite(game.bugs[i]);
  end;
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
