unit GameViewMain;

interface

uses Classes,
  CastleVectors, CastleComponentSerialize,
  CastleUIControls, CastleControls, CastleKeysMouse,

  Box, Terrain, MathUtils;

type
  TViewMain = class(TCastleView)
  published
    LabelFps: TCastleLabel;
  private
    Box : TBox;
    Terrain : TTerrain;

    LookAt : Single;
    LookLerp : Single;
  public
    constructor Create(AOwner: TComponent); override;
    procedure Start; override;
    procedure Update(const SecondsPassed: Single; var HandleInput: Boolean); override;
    function Press(const Event: TInputPressRelease): Boolean; override;
  end;

var
  ViewMain: TViewMain;

implementation

uses SysUtils;

{ TViewMain ----------------------------------------------------------------- }

constructor TViewMain.Create(AOwner: TComponent);
begin
  inherited;
  DesignUrl := 'castle-data:/gameviewmain.castle-user-interface';
end;

procedure TViewMain.Start;
begin
  inherited;

  LookAt := 0;

  Box := TBox.Create(Self);
  InsertFront(Box);
  Box.ShowBox;

  Terrain := TTerrain.Create(Self);
  InsertFront(Terrain);
  Terrain.ShowTerrain;


end;

procedure TViewMain.Update(const SecondsPassed: Single; var HandleInput: Boolean);
begin
  inherited;
  Assert(LabelFps <> nil, 'If you remove LabelFps from the design, remember to remove also the assignment "LabelFps.Caption := ..." from code');
  LabelFps.Caption := 'FPS: ' + Container.Fps.ToString;

  if Container.Pressed[KeyArrowLeft] then
    LookLerp := LookLerp + 60 * SecondsPassed;
  if Container.Pressed[KeyArrowRight] then
    LookLerp := LookLerp - 60 * SecondsPassed;

  LookLerp := Normalize(LookLerp, 0, 360);
  LookAt := LerpRotation(LookAt, LookLerp, 0.04);
  LookAt := Normalize(LookAt, 0, 360);
  Terrain.ShiftAllX(LookAt, 360);
end;

function TViewMain.Press(const Event: TInputPressRelease): Boolean;
begin
  Result := inherited;
  if Result then Exit;

end;

end.
