program GameMain;
uses SwinGame, sgTypes, SysUtils;

procedure Main();
begin
  OpenAudio();
  
  OpenGraphicsWindow('Bug Splat', 1024, 768);
  LoadDefaultColors();
  ShowSwinGameSplashScreen();

  ClearScreen(ColorWhite);
  DrawText('Hello World', ColorBlack, 'arial', 64, 370, 360);
  RefreshScreen();

  Delay(5000);
    
  CloseAudio();
  ReleaseAllResources();
end;

begin
  Main();
end.
