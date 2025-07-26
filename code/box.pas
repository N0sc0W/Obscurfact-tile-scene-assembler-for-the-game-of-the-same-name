unit Box;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils,
  CastleControls, CastleViewport;

type

  TBox = class(TCastleDesign)
  public
    //Viewport : TCastleViewport;
  private
  public
    constructor Create(AOwner : TComponent); override;
    procedure ShowBox();
  end;

implementation

constructor TBox.Create(AOwner : TComponent);
begin
  inherited;
  Url := 'castle-data:/designs/box.castle-user-interface';
  FullSize := True;
  //Exists   := False;
end;

procedure TBox.ShowBox();
begin
  //Exists := True;
end;

end.

