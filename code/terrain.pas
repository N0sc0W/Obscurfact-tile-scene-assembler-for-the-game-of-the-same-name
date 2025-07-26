unit Terrain;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Generics.Collections,

  CastleControls, CastleViewport, CastleScene, CastleVectors, CastleTransform,
  CastleImages, CastleGLImages, CastleRectangles, CastleRenderContext,

  MathUtils, TilesAndSprites;

type

  TImageTransformList = specialize TObjectList<TPlaneTrensform>;

  TTerrain = class(TCastleDesign)
  public
  private
    TileTransforms : TImageTransformList;

    BackDistance,
    MidDistance : Single;

    NWBackTiles,
    SEBackTiles,
    NWMidTiles,
    SEMidTiles: TPlaneTrensform;
    Viewport : TCastleViewport;
    NoiseState : TNoiseState;

  public
    constructor Create(AOwner : TComponent); override;
    procedure ShowTerrain();
    procedure ShiftAllX(Current, Maximal : Single);
  end;


implementation

uses
  CastleGLUtils, CastleColors, CastleRenderOptions;

constructor TTerrain.Create(AOwner : TComponent);
begin
  inherited;
  Url := 'castle-data:/designs/terrain.castle-user-interface';
  FullSize := True;
  NoiseState := TNoiseState.Create();

  Viewport := DesignedComponent('Viewport') as TCastleViewport;

  TileTransforms := TImageTransformList.Create();

end;

procedure TTerrain.ShowTerrain();
var
  IntList : TIntList;
  Tiles, MidTiles : TTileSet;
  PlaneCanvBack,
  PlaneCanvMid: TPlaneCanvas;
begin
  BackDistance := 1;
  MidDistance := 10;

  Tiles := TTileSet.Create;
  Tiles.LoadForestTiles;

  IntList := NoiseState.CircleInt(2, 2, 128, 40);
  IntList := IntListToZero(IntList);
  IntList := ResizeIntList(IntList, 4);
  IntList := PlatoToIntList(IntList, 40, 66, 2);
  IntList := PlatoToIntList(IntList, 47, 87, 4);

  PlaneCanvBack := DrawTilesAtPlane(Tiles, IntList, Self);
  NWBackTiles := PlaneCanvBack.NorthWestBack;
  SEBackTiles := PlaneCanvBack.SouthEastBack;
  Viewport.Items.Add(NWBackTiles);
  Viewport.Items.Add(SEBackTiles);

  IntList.Destroy;

  MidTiles := TTileSet.Create;
  MidTiles.LoadForestForeTiles;

  IntList := NoiseState.CircleInt(2, 2, 60, 20);
  IntList := IntListToZero(IntList);
  IntList := ResizeIntList(IntList, 2); 
  IntList := PlatoToIntList(IntList, 17, 26, 2);
  IntList := PlatoToIntList(IntList, 6, 26, 1);
  IntList := PlatoToIntList(IntList, 14, 29, 1);

  PlaneCanvMid := DrawTilesAtPlane(MidTiles, IntList, Self);
  NWMidTiles := PlaneCanvMid.NorthWestBack;
  SEMidTiles := PlaneCanvMid.SouthEastBack;
  Viewport.Items.Add(NWMidTiles);
  Viewport.Items.Add(SEMidTiles);

end;

procedure TTerrain.ShiftAllX(Current, Maximal : Single);
var
  PosBack, PosMid : TVector2;
begin

  PosBack := CanvasPositions(Current, NWBackTiles.HorSize + SEBackTiles.HorSize);
  NWBackTiles.Translation := Vector3(PosBack.X, 220, BackDistance);
  SEBackTiles.Translation := Vector3(PosBack.Y, 220, BackDistance);

  PosMid := CanvasPositions(Current, NWMidTiles.HorSize + SEMidTiles.HorSize);
  NWMidTiles.Translation := Vector3(PosMid.X, 0, MidDistance);
  SEMidTiles.Translation := Vector3(PosMid.Y, 0, MidDistance);

end;

end.

