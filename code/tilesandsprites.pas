unit TilesAndSprites;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Generics.Collections, Math,

  CastleScene, CastleImages, CastleGLImages, CastleRectangles, CastleVectors,
  CastleColors,

  MathUtils;

type
  TImageList = specialize TObjectList<TDrawableImage>;

  TTileSet = class
  private
  public
    TileW,
    TileH,
    WallH,
    OverlapH,
    OverlapV,
    OverlapW : Integer;

    Slope : Single;
    
    Top00,
    Top01,
    Top10,
    Top11,
    Center,
    CliffCenter,
    CliffTop01,
    CliffTop10,
    CliffSlope01,
    CliffSlope10,
    CliffWall01,
    CliffWall10,
    CliffBot01,
    CliffBot10,
    Walls : TImageList;

    constructor Create;
    procedure LoadForestTiles;
    procedure LoadForestForeTiles;
  end;

  TPlaneTrensform = class(TCastleImageTransform)
  private
  public  
    HorSize,
    VerSize : Single;

    constructor Create(AOwner : TComponent); override;
  end;

  TPlaneCanvas = class(TComponent)
  private
  public
    NorthWestBack,
    SouthEastBack,
    NorthWestMid,
    SouthEastMid : TPlaneTrensform;

    constructor Create(AOwner : TComponent); override;
  end;

  function TileXPosition(T : TTileSet; X : Single): Single;
  function TileRandXPosition(T : TTileSet; X : Single): Single;
  function TileYPositiom(T : TTileSet; Y : Single): Single;
  function TileRandYPosition(T : TTileSet; Y : Single): Single;
  function ModTile(Tile : TDrawableImage; X, Y : Integer): TDrawableImage;
  function ModTileBack(Tile : TDrawableImage; X, Y : Integer): TDrawableImage;
  function DrawTileView(Tiles : TTileSet; Ints : TIntList): TDrawableImage;
  function CutAndMakeCycle(LBorder, RBorder : Single; Image : TDrawableImage;
                           Owner : TComponent): TPlaneCanvas;
  //function CutAndMakeCycle(CS, TS : Single; Canv : TDrawableImage;
  //                       Owner : TComponent): TPlaneCanvas;
  function DrawTilesAtPlane(Tiles : TTileSet; IntList : TIntList;
                            Owner : TComponent): TPlaneCanvas;
  function RandImg(Tiles : TImageList): TDrawableImage;
  procedure ImageOnImage(Canv, Img : TDrawableImage; Color : TVector4;  X, Y: Single); overload;
  procedure ImageOnImage(Canv, Img : TDrawableImage; X, Y: Single); overload;
  procedure DrawIntsAtImg(Tiles : TTileSet; Pos : Single; IntList : TIntList;
                          Start, Finish : Integer; Img : TDrawableImage; Dir : Boolean);

implementation

function RandImg(Tiles : TImageList): TDrawableImage;
begin
  Result := Tiles[Random(Tiles.Count)];
end;

function TileXPosition(T : TTileSet; X : Single): Single;
begin
  Result := T.TileW * X + T.OverlapH - T.OverlapH;
end;

function TileRandXPosition(T : TTileSet; X : Single): Single;
begin
  Result := T.TileW * X + T.OverlapH - T.OverlapH + Random(T.OverlapH * 2);
end;

function TileYPositiom(T : TTileSet; Y : Single): Single;
begin
  Result := T.TileH * Y - Y * Y * T.Slope - T.OverlapV;
end;

function TileRandYPosition(T : TTileSet; Y : Single): Single;
begin
  Result := T.TileH * Y - Y * Y * T.Slope - T.OverlapV + Random(T.OverlapV * 2);
end;

function ModTile(Tile : TDrawableImage; X, Y : Integer): TDrawableImage;
begin
  Result := Tile;
  Result.Color := GetColor(X, Y);
end;

function ModTileBack(Tile : TDrawableImage; X, Y : Integer): TDrawableImage;
begin
  Result := Tile;
  Result.Color := GetColor(X, Y);
end;

procedure ImageOnImage(Canv, Img : TDrawableImage; X, Y: Single);
var
  NewTile: TDrawableImage;
begin
  NewTile := Img;
  Canv.DrawFrom(Img,
                FloatRectangle(X, Y, Img.Width, Img.Height),
                Img.FloatRect);
end;

procedure ImageOnImage(Canv, Img : TDrawableImage; Color : TVector4;  X, Y: Single);
var
  NewTile : TDrawableImage;
begin
  NewTile := Img;
  NewTile.Color := Color;
  Canv.DrawFrom(Img,
                FloatRectangle(X, Y, Img.Width, Img.Height),
                Img.FloatRect);
end;

function DrawTileView(Tiles : TTileSet; Ints : TIntList): TDrawableImage;
var
  I, J, K : Integer;
  CliffCoords : Coord3D;
  Banned : Coord2D;
begin
  Result := TDrawableImage.Create(Tiles.TileW * Ints.Count, 1024, TRGBAlphaImage, True);
  CliffCoords := Coord3D.Create;
  Banned := Coord2D.Create;

  // Horizon line: \\
  for I := 1 to Ints.Count-2 do
  begin
    // If cliff is found: \\
    if (Ints.Items[I] - 1 > Ints.Items[I-1]) then
    begin
      ImageOnImage(Result, RandImg(Tiles.CliffTop01), Vector4(1, 1, 1, 1),
                   TileXPosition(Tiles, I), Tiles.TileH*2 + TileRandYPosition(Tiles, Ints.Items[I]));
      for K := 0 to Ints.Items[I] do
        if K = Ints.Items[I-1] then
        begin
          for J := Ints.Items[I] downto K do
            AddToEnd(CliffCoords, I+Ints.Items[I]-J, K, J);
          Break;
        end
    end
    // If horizon line is smooth: \\
    else if (Ints.Items[I] > Ints.Items[I-1]) and (Ints.Items[I] > Ints.Items[I+1]) then
    begin
      ImageOnImage(Result, RandImg(Tiles.Top00), Vector4(1, 1, 1, 1),
                   TileRandXPosition(Tiles, I), Tiles.TileH*2 + TileRandYPosition(Tiles, Ints.Items[I]-1));
      AddToEnd(Banned, Ints.Items[I]-1, I)
    end
    else if (Ints.Items[I] > Ints.Items[I-1]) then
    begin
      ImageOnImage(Result, RandImg(Tiles.Top01), Vector4(1, 1, 1, 1),
                   TileRandXPosition(Tiles, I), Tiles.TileH*2 + TileRandYPosition(Tiles, Ints.Items[I-1]));
      AddToEnd(Banned, Ints.Items[I]-1, I)
    end
    else
      ImageOnImage(Result, RandImg(Tiles.Top11), Vector4(1, 1, 1, 1),
                   TileRandXPosition(Tiles, I), Tiles.TileH*2 + TileRandYPosition(Tiles, Ints.Items[I]))
  end;
  // Filling in tiles: \\
  for I := IntListMax(Ints) downto 0 do
    for J := 1 to Ints.Count-2 do
    begin
      if I >= Ints[J] then
        Continue;
      if IsIn(CliffCoords, J, I) = 'T' then
        ImageOnImage(Result, RandImg(Tiles.CliffSlope01),
                     TileXPosition(Tiles, J), Tiles.TileH*2 + TileRandYPosition(Tiles, I))
      else if (IsIn(CliffCoords, J, I) = 'C') and (Ints[J-1] >= I) then
       ImageOnImage(Result, RandImg(Tiles.CliffCenter),
                    TileXPosition(Tiles, J), Tiles.TileH*2 + TileRandYPosition(Tiles, I))
      else if IsIn(CliffCoords, J, I) = 'C' then
        ImageOnImage(Result, RandImg(Tiles.CliffWall01),
                     TileXPosition(Tiles, J), Tiles.TileH*2 + TileRandYPosition(Tiles, I))
      else if (IsIn(CliffCoords, J, I) = 'B') and (Ints[J-1] = I) then
        ImageOnImage(Result, RandImg(Tiles.CliffBot01),
                     TileXPosition(Tiles, J), Tiles.TileH*2 + TileRandYPosition(Tiles, I))
      else if (IsIn(CliffCoords, J, I) = 'B') then
        ImageOnImage(Result, RandImg(Tiles.CliffCenter),
                     TileXPosition(Tiles, J), Tiles.TileH*2 + TileRandYPosition(Tiles, I))
      else if IsIn(Banned, I, J) <> 'Y' then
        ImageOnImage(Result, RandImg(Tiles.Center),
                     TileRandXPosition(Tiles, J), Tiles.TileH*2 + TileRandYPosition(Tiles, I));
    end;

  for I := 0 to 3 do
    for J := 1 to Ints.Count-2 do
    begin
      ImageOnImage(Result, RandImg(Tiles.Walls),
                   TileRandXPosition(Tiles, J),
                   Tiles.TileH - TileRandYPosition(Tiles, I)
                   + (Ints[J] / 5) * Tiles.OverlapW);
    end;
end;

function DrawBackTileView(Tiles : TTileSet; Ints : TIntList): TDrawableImage;
var
  I, J, K : Integer;
  CliffCoords : Coord3D;
  Banned : Coord2D;
begin
  Result := TDrawableImage.Create(Tiles.TileW * Ints.Count, 1024, TRGBAlphaImage, True);
  CliffCoords := Coord3D.Create;
  Banned := Coord2D.Create;

  // Horizon line: \\
  for I := Ints.Count-2 downto 1 do
  begin
    // If cliff is found: \\
    if (Ints.Items[I] > Ints.Items[I+1] + 1) then
    begin
      ImageOnImage(Result, RandImg(Tiles.CliffTop10), Vector4(1, 1, 1, 1),
                   TileXPosition(Tiles, I), Tiles.TileH * 2 + TileRandYPosition(Tiles, Ints.Items[I]));
      for K := 0 to Ints.Items[I] do
        if K = Ints.Items[I+1] then
        begin
          for J := Ints.Items[I] downto K do
            AddToStart(CliffCoords, I-(Ints.Items[I] - J), K, J);
          Break;
        end;
    end
    // If horizon line is smooth: \\

    else if (Ints.Items[I] > Ints.Items[I-1]) and (Ints.Items[I] > Ints.Items[I+1]) then
    begin
      ImageOnImage(Result, RandImg(Tiles.Top00), Vector4(1, 1, 1, 1),
                   TileRandXPosition(Tiles, I), Tiles.TileH*2+TileRandYPosition(Tiles, Ints.Items[I]));
      AddToEnd(Banned, Ints.Items[I]-1, I)
    end
    else if (Ints.Items[I] > Ints.Items[I+1]) then
    begin
      ImageOnImage(Result, RandImg(Tiles.Top10), Vector4(1, 1, 1, 1),
                   TileRandXPosition(Tiles, I), Tiles.TileH*2 + TileRandYPosition(Tiles, Ints.Items[I+1]));
      AddToEnd(Banned, Ints.Items[I]-1, I)
    end
    else
      ImageOnImage(Result, RandImg(Tiles.Top11), Vector4(1, 1, 1, 1),
                   TileRandXPosition(Tiles, I), Tiles.TileH*2 + TileRandYPosition(Tiles, Ints.Items[I]))
  end;
  // Filling in tiles: \\
  for I := IntListMax(Ints) downto 0 do
    for J := Ints.Count-2 downto 1 do
    begin
      if I >= Ints[J] then
        Continue;
      if IsIn(CliffCoords, J, I) = 'T' then
       ImageOnImage(Result, RandImg(Tiles.CliffSlope10),
                    TileXPosition(Tiles, J), Tiles.TileH * 2 + TileRandYPosition(Tiles, I))
      else if (IsIn(CliffCoords, J, I) = 'C') and (Ints[J + 1] >= I) then
       ImageOnImage(Result, RandImg(Tiles.CliffCenter),
                    TileXPosition(Tiles, J), Tiles.TileH * 2 + TileRandYPosition(Tiles, I))
      else if (IsIn(CliffCoords, J, I) = 'C') then
       ImageOnImage(Result, RandImg(Tiles.CliffWall10),
                    TileXPosition(Tiles, J), Tiles.TileH * 2 + TileRandYPosition(Tiles, I))
      else if (IsIn(CliffCoords, J, I) = 'B') and (Ints[J + 1] = I) then
        ImageOnImage(Result, RandImg(Tiles.CliffBot10),
                     TileXPosition(Tiles, J), Tiles.TileH * 2 + TileRandYPosition(Tiles, I))
      else if (IsIn(CliffCoords, J, I) = 'B') then
        ImageOnImage(Result, RandImg(Tiles.CliffCenter),
                     TileXPosition(Tiles, J), Tiles.TileH * 2 + TileRandYPosition(Tiles, I))
      else if IsIn(Banned, I, J) <> 'Y' then
       ImageOnImage(Result, RandImg(Tiles.Center),
                    TileRandXPosition(Tiles, J), Tiles.TileH * 2 + TileRandYPosition(Tiles, I));
    end;

  for I:=0 to 3 do
    for J:=Ints.Count-2 downto 1 do
    begin
      ImageOnImage(Result, RandImg(Tiles.Walls),
                   TileRandXPosition(Tiles, J),
                   (Tiles.TileH-TileRandYPosition(Tiles, I))
                   + (Ints[J] / 5) * Tiles.OverlapW);
    end;
end;

procedure DrawIntsAtImg(Tiles : TTileSet; Pos : Single; IntList : TIntList;
                        Start, Finish : Integer; Img : TDrawableImage; Dir : Boolean);
var
  IList: TIntList;
  TView: TDrawableImage;
begin
  IList:=SliceIntList(IntList, Start-1, Finish+1);
  if Dir then
    TView:=DrawTileView(Tiles, IList)
  else
    TView:=DrawBackTileView(Tiles, IList);
  Img.DrawFrom(TView,
               FloatRectangle(Start*Tiles.TileW-Pos, 0, TView.Width, TView.Height),
               FloatRectangle(0, 0, TView.Width, TView.Height));
end;

function CutAndMakeCycle(LBorder, RBorder : Single; Image : TDrawableImage;
                         Owner : TComponent): TPlaneCanvas;
var
  Size, Half: Single;
  NWPart, SEPart, Canv: TDrawableImage;
  CImage: TCastleImage;
begin

  Size := RBorder-LBorder;
  Half := Size/2;
  Canv := TDrawableImage.Create(Trunc(Size+1024), 1024, TRGBAlphaImage, True);

  Result := TPlaneCanvas.Create(Owner);
  Result.NorthWestBack.HorSize := Half;
  Result.NorthWestBack.VerSize := 1024;
  Result.SouthEastBack.HorSize := Half;
  Result.SouthEastBack.VerSize := 1024;

  Canv.DrawFrom(Image, FloatRectangle(0, 0, 512, Canv.Height),
                FloatRectangle(RBorder-512, 0, 512, Image.Height));
  Canv.DrawFrom(Image, FloatRectangle(512, 0, Size, Canv.Height),
                FloatRectangle(LBorder, 0, Size, Image.Height));
  Canv.DrawFrom(Image, FloatRectangle(512+Size, 0, 512, Canv.Height),
                FloatRectangle(LBorder, 0, 512, Image.Height));

  NWPart := TDrawableImage.Create(Trunc(Half), 1024, TRGBAlphaImage, True);
  NWPart.DrawFrom(Canv, FloatRectangle(0, 0, Half, Canv.Height),
                  FloatRectangle(512, 0, Half, Canv.Height));
  CImage := NWPart.GetContents(TRGBAlphaImage);
  Result.NorthWestBack.LoadFromImage(CImage, True);

  SEPart := TDrawableImage.Create(Trunc(Half), 1024, TRGBAlphaImage, True);
  SEPart.DrawFrom(Canv, FloatRectangle(0, 0, Half, Canv.Height),
                  FloatRectangle(Half+512, 0, Half, Canv.Height));
  CImage := SEPart.GetContents(TRGBAlphaImage);
  Result.SouthEastBack.LoadFromImage(CImage, True);

end;

function DrawTilesAtPlane(Tiles : TTileSet; IntList : TIntList; Owner : TComponent): TPlaneCanvas;
var
  Canv : TDrawableImage;
  I : Integer;
  CanvSize, CuttedSize : Single;
  Valleys, Pikes : TIntList;
  Adder : Single;
begin
  CanvSize   := Tiles.TileW*(IntList.Count+1);
  CuttedSize := Tiles.TileW*(IntList.Count/2);

  Valleys := MinExcessPoints(IntList);
  Pikes := MaxExcessPoints(IntList);

  Canv := TDrawableImage.Create(Trunc(CanvSize), 1024, TRGBAlphaImage, True);
  Canv.Alpha := acBlending;

  Result := TPlaneCanvas.Create(Owner);
  Result.NorthWestBack.HorSize := CuttedSize;
  Result.NorthWestBack.VerSize := 1024;
  Result.SouthEastBack.HorSize := CuttedSize;
  Result.SouthEastBack.VerSize := 1024;

  Adder := Min(Valleys[0]*Tiles.TileW, Pikes[0]*Tiles.TileW) + Tiles.TileW;

  if Valleys[0] < Pikes[0] then
  begin
    for I := 0 to Valleys.Count-2 do
    begin
      DrawIntsAtImg(Tiles, Adder, IntList, Valleys[I]+1, Pikes[I], Canv, True);
      DrawIntsAtImg(Tiles, Adder, IntList, Pikes[I]+1, Valleys[I+1], Canv, False);
    end;
    DrawIntsAtImg(Tiles, Adder, IntList, Valleys[Valleys.Count-1]+1, Pikes[Pikes.Count-1], Canv, True);
    DrawIntsAtImg(Tiles, Adder, IntList, Pikes[Pikes.Count-1]+1, Valleys[0], Canv, False);
  end
  else
  begin
    for I := 0 to Pikes.Count-2 do
    begin
      DrawIntsAtImg(Tiles, Adder, IntList, Pikes[I]+1, Valleys[I], Canv, False);
      DrawIntsAtImg(Tiles, Adder, IntList, Valleys[I]+1, Pikes[I+1], Canv, True);
    end;
    DrawIntsAtImg(Tiles, Adder, IntList, Pikes[Pikes.Count-1]+1, Valleys[Valleys.Count-1], Canv, False);
    DrawIntsAtImg(Tiles, Adder, IntList, Valleys[Valleys.Count-1]+1, Pikes[0], Canv, True);
  end;

  Result := CutAndMakeCycle(Tiles.TileW+Tiles.TileW/2*Tiles.OverlapH,
                            CanvSize, Canv, Owner);

end;

constructor TPlaneTrensform.Create(AOwner : TComponent);
begin
  inherited;

end;

constructor TPlaneCanvas.Create(AOwner : TComponent);
begin
  inherited;

  NorthWestBack := TPlaneTrensform.Create(Self);
  SouthEastBack := TPlaneTrensform.Create(Self);

  NorthWestMid := TPlaneTrensform.Create(Self);
  NorthWestMid := TPlaneTrensform.Create(Self);

end;

constructor TTileSet.Create;
begin
  Top00       := TImageList.Create;
  Top01       := TImageList.Create;
  Top10       := TImageList.Create;
  Top11       := TImageList.Create;
  Center      := TImageList.Create;
  CliffCenter := TImageList.Create;
  CliffTop01  := TImageList.Create;
  CliffTop10  := TImageList.Create;
  CliffWall01 := TImageList.Create;
  CliffWall10 := TImageList.Create;
  CliffSlope01:= TImageList.Create;
  CliffSlope10:= TImageList.Create;
  CliffBot01  := TImageList.Create;
  CliffBot10  := TImageList.Create;
  Walls       := TImageList.Create;
end;

procedure TTileSet.LoadForestTiles;
begin
  TileW := 48;
  TileH := 32;
  WallH := 128;
  OverlapH := 4;
  OverlapV := 8;
  OverlapW := 32;
  Slope := 1.1;

  Top00.Add(TDrawableImage.Create('castle-data:/tiles/forest/far/top_00_a.png')); 
  Top00.Add(TDrawableImage.Create('castle-data:/tiles/forest/far/top_00_b.png'));
  Top01.Add(TDrawableImage.Create('castle-data:/tiles/forest/far/top_01_a.png'));
  Top10.Add(TDrawableImage.Create('castle-data:/tiles/forest/far/top_10_a.png'));
  Top11.Add(TDrawableImage.Create('castle-data:/tiles/forest/far/top_11_a.png')); 
  Top11.Add(TDrawableImage.Create('castle-data:/tiles/forest/far/top_11_b.png'));
  Center.Add(TDrawableImage.Create('castle-data:/tiles/forest/far/center_a.png')); 
  Center.Add(TDrawableImage.Create('castle-data:/tiles/forest/far/center_b.png'));
  CliffCenter.Add(TDrawableImage.Create('castle-data:/tiles/forest/far/cliff_center_a.png'));
  CliffTop01.Add(TDrawableImage.Create('castle-data:/tiles/forest/far/cliff_top_01_a.png'));
  CliffTop10.Add(TDrawableImage.Create('castle-data:/tiles/forest/far/cliff_top_10_a.png'));
  CliffWall01.Add(TDrawableImage.Create('castle-data:/tiles/forest/far/cliff_wall_01_a.png'));
  CliffWall10.Add(TDrawableImage.Create('castle-data:/tiles/forest/far/cliff_wall_10_a.png'));
  CliffSlope01.Add(TDrawableImage.Create('castle-data:/tiles/forest/far/cliff_slope_01_a.png'));
  CliffSlope10.Add(TDrawableImage.Create('castle-data:/tiles/forest/far/cliff_slope_10_a.png'));
  CliffBot01.Add(TDrawableImage.Create('castle-data:/tiles/forest/far/cliff_bot_01_a.png'));
  CliffBot10.Add(TDrawableImage.Create('castle-data:/tiles/forest/far/cliff_bot_10_a.png'));
  Walls.Add(TDrawableImage.Create('castle-data:/tiles/forest/far/wall_a.png'));
  Walls.Add(TDrawableImage.Create('castle-data:/tiles/forest/far/wall_b.png'));  
  Walls.Add(TDrawableImage.Create('castle-data:/tiles/forest/far/wall_c.png'));

end;

procedure TTileSet.LoadForestForeTiles;
begin

  TileW := 128;
  TileH := 64;
  WallH := 64;
  OverlapH := 0;
  OverlapV := 0;
  OverlapW := 0;
  Slope := 0;

  Top00.Add(TDrawableImage.Create('castle-data:/tiles/forest/mid/top_00_a.png'));
  Top01.Add(TDrawableImage.Create('castle-data:/tiles/forest/mid/top_01_a.png'));
  Top10.Add(TDrawableImage.Create('castle-data:/tiles/forest/mid/top_10_a.png'));
  Top11.Add(TDrawableImage.Create('castle-data:/tiles/forest/mid/top_11_a.png'));
  Top11.Add(TDrawableImage.Create('castle-data:/tiles/forest/mid/top_11_b.png'));
  Center.Add(TDrawableImage.Create('castle-data:/tiles/forest/mid/center_a.png'));
  CliffCenter.Add(TDrawableImage.Create('castle-data:/tiles/forest/mid/cliff_center_a.png'));
  CliffTop01.Add(TDrawableImage.Create('castle-data:/tiles/forest/mid/cliff_top_01_a.png'));
  CliffTop10.Add(TDrawableImage.Create('castle-data:/tiles/forest/mid/cliff_top_10_a.png'));
  CliffWall01.Add(TDrawableImage.Create('castle-data:/tiles/forest/mid/cliff_wall_01_a.png'));
  CliffWall10.Add(TDrawableImage.Create('castle-data:/tiles/forest/mid/cliff_wall_10_a.png'));
  CliffSlope01.Add(TDrawableImage.Create('castle-data:/tiles/forest/mid/cliff_slope_10_a.png'));
  CliffSlope10.Add(TDrawableImage.Create('castle-data:/tiles/forest/mid/cliff_slope_10_a.png'));
  CliffBot01.Add(TDrawableImage.Create('castle-data:/tiles/forest/mid/cliff_bot_01_a.png'));
  CliffBot10.Add(TDrawableImage.Create('castle-data:/tiles/forest/mid/cliff_bot_10_a.png'));
  Walls.Add(TDrawableImage.Create('castle-data:/tiles/forest/mid/wall_a.png'));

end;

end.

