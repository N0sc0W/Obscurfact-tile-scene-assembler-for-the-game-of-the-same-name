unit MathUtils;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Math, Generics.Collections, CastleVectors,

  FastNoiseLite;

type
  TIntList = specialize TList<Integer>;
  TStrList = specialize TList<String>;
  TVector3List = specialize TList<TVector3>;

  TNoiseState = class
  private
    FNL : FNL_State;
  public
    constructor Create();
    function CircleInt(X, Y, Len, Rad : Integer): TIntList;
  end;

  Coord2D = class
  public
    Xs,
    Ys : TIntList;
    constructor Create;
  end;

  Coord3D = class
  public
    Xs,
    Ys,
    Zs : TIntList;
    constructor Create;
  end;

  RGBGradientMap = record
    Colors : array [0..7, 0..7] of TVector4;
  end;

  function CanvasPositions(Deg, CanvWids : Single): TVector2;
  function Proportion(Current, Maximal, New : Single): Single;
  function Normalize(Count, Min, Max : Single): Single;
  function LerpRotation(Current, Target, Speed : Single): Single;
  function SliceIntList(L : TIntList; Start, Finish : Integer): TIntList;
  function IntListMax(L : TIntList): Integer;
  function IntListMin(L : TIntList): Integer;
  function FindValleys(L : TIntList): TIntList;
  function FindPikes(L : TIntList): TIntList;
  function MinExcessPoints(L : TIntList): TIntList;
  function MaxExcessPoints(L : TIntList): TIntList;
  function IntListToZero(L : TIntList): TIntList;
  function ResizeIntList(L : TIntList; M : Integer): TIntList; 
  function PlatoToIntList(L : TIntList; Start, Finish, Adder : Integer): TIntList;
  function AddRandToIntList(L : TIntList; Adder : Integer): TIntList;
  //function SetIntListCount(L : TIntList; C : Integer): TIntList;
  //function IsIn(L : TIntList; X : Integer): Boolean; overload;   
  function IsIn(C : Coord2D; X, Y : Integer): Char; overload;
  function IsIn(C : Coord3D; X, Y : Integer): Char; overload;
  function GetColor(X, Y : Integer): TVector4;
  procedure AddToEnd(L : TIntList; X : Integer); overload;
  procedure AddToEnd(C : Coord2D; X, Y : Integer); overload;
  procedure AddToEnd(C : Coord3D; X, Y, Z : Integer); overload;
  procedure AddToStart(C : Coord3D; X, Y, Z : Integer); overload;
  procedure ShowAll(L : TIntList); overload;
  procedure ShowAll(C : Coord3D); overload;
  procedure PrintIntList(L : TIntList);
  procedure PrintVector3List(L : TVector3List);

  function RandFromStrList(StrList : TStrList): String;

const
  SHADOW_MAP : RGBGradientMap = (
  Colors: (
    (
      (X: 0.4; Y: 0.4; Z: 0.4; W: 1), (X: 0.45; Y: 0.45; Z: 0.45; W: 1), (X: 0.5; Y: 0.5; Z: 0.5; W: 1),
      (X: 0.6; Y: 0.6; Z: 0.6; W: 1), (X: 0.7; Y: 0.7; Z: 0.7; W: 1), (X: 0.8; Y: 0.8; Z: 0.8; W: 1),
      (X: 0.9; Y: 0.9; Z: 0.9; W: 1), (X: 1.0; Y: 1.0; Z: 1.0; W: 1)
    ),
    (
      (X: 0.45; Y: 0.45; Z: 0.45; W: 1), (X: 0.5; Y: 0.5; Z: 0.5; W: 1), (X: 0.55; Y: 0.55; Z: 0.55; W: 1),
      (X: 0.65; Y: 0.65; Z: 0.65; W: 1), (X: 0.75; Y: 0.75; Z: 0.75; W: 1), (X: 0.85; Y: 0.85; Z: 0.85; W: 1),
      (X: 0.95; Y: 0.95; Z: 0.95; W: 1), (X: 1.0; Y: 1.0; Z: 1.0; W: 1)
    ),
    (
      (X: 0.5; Y: 0.5; Z: 0.5; W: 1), (X: 0.55; Y: 0.55; Z: 0.55; W: 1), (X: 0.6; Y: 0.6; Z: 0.6; W: 1),
      (X: 0.7; Y: 0.7; Z: 0.7; W: 1), (X: 0.8; Y: 0.8; Z: 0.8; W: 1), (X: 0.9; Y: 0.9; Z: 0.9; W: 1),
      (X: 0.95; Y: 0.95; Z: 0.95; W: 1), (X: 1.0; Y: 1.0; Z: 1.0; W: 1)
    ),
    (
      (X: 0.6; Y: 0.6; Z: 0.6; W: 1), (X: 0.65; Y: 0.65; Z: 0.65; W: 1), (X: 0.7; Y: 0.7; Z: 0.7; W: 1),
      (X: 0.75; Y: 0.75; Z: 0.75; W: 1), (X: 0.85; Y: 0.85; Z: 0.85; W: 1), (X: 0.9; Y: 0.9; Z: 0.9; W: 1),
      (X: 0.97; Y: 0.97; Z: 0.97; W: 1), (X: 1.0; Y: 1.0; Z: 1.0; W: 1)
    ),
    (
      (X: 0.7; Y: 0.7; Z: 0.7; W: 1), (X: 0.75; Y: 0.75; Z: 0.75; W: 1), (X: 0.8; Y: 0.8; Z: 0.8; W: 1),
      (X: 0.85; Y: 0.85; Z: 0.85; W: 1), (X: 0.9; Y: 0.9; Z: 0.9; W: 1), (X: 0.95; Y: 0.95; Z: 0.95; W: 1),
      (X: 0.98; Y: 0.98; Z: 0.98; W: 1), (X: 1.0; Y: 1.0; Z: 1.0; W: 1)
    ),
    (
      (X: 0.8; Y: 0.8; Z: 0.8; W: 1), (X: 0.85; Y: 0.85; Z: 0.85; W: 1), (X: 0.9; Y: 0.9; Z: 0.9; W: 1),
      (X: 0.92; Y: 0.92; Z: 0.92; W: 1), (X: 0.95; Y: 0.95; Z: 0.95; W: 1), (X: 0.97; Y: 0.97; Z: 0.97; W: 1),
      (X: 0.99; Y: 0.99; Z: 0.99; W: 1), (X: 1.0; Y: 1.0; Z: 1.0; W: 1)
    ),
    (
      (X: 0.9; Y: 0.9; Z: 0.9; W: 1), (X: 0.92; Y: 0.92; Z: 0.92; W: 1), (X: 0.94; Y: 0.94; Z: 0.94; W: 1),
      (X: 0.96; Y: 0.96; Z: 0.96; W: 1), (X: 0.97; Y: 0.97; Z: 0.97; W: 1), (X: 0.98; Y: 0.98; Z: 0.98; W: 1),
      (X: 0.995; Y: 0.995; Z: 0.995; W: 1), (X: 1.0; Y: 1.0; Z: 1.0; W: 1)
    ),
    (
      (X: 1.0; Y: 1.0; Z: 1.0; W: 1), (X: 1.0; Y: 1.0; Z: 1.0; W: 1), (X: 1.0; Y: 1.0; Z: 1.0; W: 1),
      (X: 1.0; Y: 1.0; Z: 1.0; W: 1), (X: 1.0; Y: 1.0; Z: 1.0; W: 1), (X: 1.0; Y: 1.0; Z: 1.0; W: 1),
      (X: 1.0; Y: 1.0; Z: 1.0; W: 1), (X: 1.0; Y: 1.0; Z: 1.0; W: 1)
    )
  )
);

implementation

constructor TNoiseState.Create();
begin
  FNL := fnlCreateState();
  FNL.frequency := 2;
  FNL.noise_type := FNL_NOISE_OPENSIMPLEX2;
  FNL.cellular_distance_func := FNL_CELLULAR_DISTANCE_EUCLIDEAN;
  FNL.domain_warp_type := FNL_DOMAIN_WARP_OPENSIMPLEX2;
  FNL.domain_warp_amp := 6.0;
  FNL.fractal_type := FNL_FRACTAL_PINGPONG;
  FNL.weighted_strength := 2;

end;

function TNoiseState.CircleInt(X, Y, Len, Rad : Integer): TIntList;
var
  S, X_, Y_ : Single;
  I : Integer;
begin
  Result := TIntList.Create();
  S := Pi * 2 / Len;
  for I := 1 to Len do
  begin
    X_ := X + (sin(S * I) * Rad + Rad) / 100;
    Y_ := Y + (cos(S * I) * Rad + Rad) / 100;
    Result.Add(Trunc((fnlGetNoise2D(@FNL, X_, Y_) + 1.0) / 2.0 * 100));
  end;
end;

constructor Coord2D.Create;
begin
  Xs := TIntList.Create();
  Ys := TIntList.Create();
end;

constructor Coord3D.Create;
begin
  Xs := TIntList.Create();
  Ys := TIntList.Create();
  Zs := TIntList.Create();
end;

function GetColor(X, Y : Integer): TVector4;
begin
  Result := SHADOW_MAP.Colors[min(Y, Length(SHADOW_MAP.Colors)-1), min(X-1, Length(SHADOW_MAP.Colors[0])-1)];
end;

function Proportion(Current, Maximal, New : Single): Single;
begin
  Result := (Current / Maximal) * New;
end;

function Normalize(Count, Min, Max : Single): Single;
begin
  if Count < Min then
    Result := Count + Max
  else if Count >= Max then
    Result := Count - Max
  else
    Result := Count;
end;

function LerpRotation(Current, Target, Speed : Single): Single;
begin
  if (Target < 120) and (Current > 240) then
    Result := Current + (360 - Current + Target) * Speed
  else if (Target > 240) and (Current < 120) then
    Result := Current - (Current + (360 - Target)) * Speed
  else
    Result := Current + (Target - Current) * Speed;
end;


function CanvasPositions(Deg, CanvWids : Single): TVector2;
var
  CanvWid, Look : Single;
begin
  Look := Proportion(Deg, 360, CanvWids);
  CanvWid := CanvWids / 2;
  if (Look < CanvWid * 0.9) then
    Result := Vector2(Look, Look - CanvWid)
  else if (Look < CanvWid + CanvWid * 0.9) then
    Result := Vector2(Look - CanvWid * 2, Look - CanvWid)
  else
    Result := Vector2(Look - CanvWid * 2, Look - CanvWid * 3);
end;

{
function CanvasPositions(Deg, CanvWids : Single): TVector4;
var
  CanvWid, Look : Single;
begin
  Look := Proportion(Deg, 360, CanvWids);
  CanvWid := CanvWids / 2;
  if (Look < CanvWid * 0.9) then
    Result := Vector4(Look, 0, Look - CanvWid, 1)
  else if (Look < CanvWid + CanvWid * 0.9) then
    Result := Vector4(Look - CanvWid * 2, 1, Look - CanvWid, 0)
  else
    Result := Vector4(Look - CanvWid * 2, 0, Look - CanvWid * 3, 1);
end;
}
function SliceIntList(L : TIntList; Start, Finish : Integer): TIntList;
var
  I : Integer;
begin
  //if (Start > Finish) or (abs(Start) > (L.Count-1)*2) or (abs(Finish) > (L.Count-1)*2) then
  //  raise ERangeError.Create('Incorrect index for list');

  Result := TIntList.Create();

  if Start > Finish then
  begin
    for I := Start to L.Count-1 do
      Result.Add(L[I]); 
    for I := 0 to Finish do
      Result.Add(L[I]);
  end
  else
  begin
    if Start < 0 then
      for I := L.Count+Start to L.Count-1 do
        Result.Add(L[I]);

    for I := max(0, Start) to min(L.Count-1, Finish) do
        Result.Add(L[I]);

    if Finish > L.Count-1 then
      for I := 0 to Finish-L.Count-1 do
        Result.Add(L[I]);
  end;
end;

function IntListMax(L : TIntList): Integer;
var
  I : Integer;
begin
  Result := L.Items[0];
  if L.Count = 1 then
    Exit;

  for I := 1 to L.Count-1 do
    if (Result < L.Items[I]) then
      Result := L.Items[I];
end;

function IntListMin(L : TIntList): Integer;
var
  I : Integer;
begin
  Result := L.Items[0];
  if L.Count = 1 then
    Exit;

  for I := 1 to L.Count-1 do
    if (Result < L.Items[I]) then
      Result := L.Items[I];
end;
{
function SetIntListCount(L : TIntList; C : Integer): TIntList;
var
  Dists, I : Integer;
begin     
  Dists := L.Count;
  if L.Count < C then
    for I := 0 to L.Count-2 do
      if (L[I+1]-L[I]) < Dists then
        Dists := I;
  L.Remove(I);
  Result := L;
  Result := SetIntListCount(Result, C);
end;
}

function MinExcessPoints(L : TIntList): TIntList;
var
  I, First : Integer;
  Open : Boolean;
begin
  Result := TIntList.Create;
  Open := True;
  First := 0;

  for I := 1 to L.Count-2 do
  begin
    if (L[I-1] > L[I]) then
    begin
      Open := True;
      First := I
    end;
    if Open and ((L[I+1] > L[I]) or (I = L.Count-2)) then
    begin
      Result.Add(Trunc((First+I)/2));
      Open := False;
    end;
  end;

  if L[0] = L[L.Count-1] then
  begin
    First := (Result[0] + Result[Result.Count-1]) mod (L.Count-1);
    Result.Delete(Result.Count-1);
    Result.Delete(0);
    if First < L.Count-1 then
      Result.Insert(0, First)
    else
      Result.Add(First);
  end;

end;

function MaxExcessPoints(L : TIntList): TIntList;
var
  I, First : Integer;
  Open : Boolean;
begin
  Result := TIntList.Create;
  Open := True;
  First := 0;

  for I := 1 to L.Count-2 do
  begin
    if (L[I-1] < L[I]) then
    begin
      Open := True;
      First := I
    end;
    if Open and ((L[I+1] < L[I]) or (I = L.Count-2)) then
    begin
      Result.Add(Trunc((First+I)/2));
      Open := False;
    end;
  end;

  if (L[0] = L[L.Count-1]) and (L[0] = (L[Result[0]])) then
  begin
    First := (Result[0] + Result[Result.Count-1]) mod (L.Count-1);
    Result.Delete(Result.Count-1);
    Result.Delete(0);
    if First < L.Count-1 then
      Result.Insert(0, First)
    else
      Result.Add(First);
  end;

end;

function FindValleys(L : TIntList): TIntList;
var
  I, FirstNum, LastValue : Integer;
  Open, AddLast : Boolean;
begin
  Result := TIntList.Create;
  Open := False;

  if (L[0] = L[L.Count-1]) then
  begin
    I := L.Count-1;
    while (I > 0) do
    begin
      if (L[I] > L[I-1]) then
      begin
        I := 1;
        Break
      end
      else if (L[I] < L[I-1]) then
      begin
        FirstNum := I;
        Open := True;
        //Break;
      end;
      I -= 1;
    end;

    if Open then
    begin
      I := 0;
      while (I < L.Count-2) do
      begin
        if (L[I] > L[I+1]) then
          Break
        else if (L[I] < L[I+1]) then
        begin
          //Result.Add(Trunc((FirstNum+I) mod L.Count));
          LastValue := Trunc((FirstNum+I) mod L.Count);
          AddLast := True;
          Open := False;
          Break;
        end;
        I += 1;
      end;
    end;
  end
  else
    I := 1;

  while I <= L.Count-2 do
  begin
    if (L[I-1] > L[I]) and (L[I+1] >= L[I]) then
    begin
      Open := True;
      FirstNum := I;
    end;    
    if (L[I+1] > L[I]) and Open then
    begin
      Open := False;
      Result.Add(Trunc((FirstNum+I)/2));
    end;
    I += 1;
  end;
  
  if AddLast then
    Result.Add(LastValue);

end;


function FindPikes(L : TIntList): TIntList;
var
  I, FirstNum, LastValue : Integer;
  Open, AddLast : Boolean;
begin
  Result := TIntList.Create();
  Open := False;
  AddLast := False;

  if (L[0] = L[L.Count-1]) then
  begin
    I := L.Count-1;
    while (I > 0) do
    begin
      if (L[I] < L[I-1]) then
      begin
        I := 1;
        Break
      end
      else if (L[I] > L[I-1]) then
      begin
        FirstNum := I;
        Open := True;
        //Break;
      end;
      I -= 1;
    end;

    if Open then
    begin
      I := 0;
      while (I < L.Count-2) do
      begin
        if (L[I] < L[I+1]) then
          Break
        else if (L[I] > L[I+1]) then
        begin
          //Result.Add(Trunc((FirstNum+I) mod L.Count));
          LastValue := Trunc((FirstNum+I) mod L.Count);
          AddLast := True;
          Open := False;
          Break;
        end;
        I += 1;
      end;
    end;
  end
  else
    I := 1;

  while I <= L.Count-2 do
  begin
    if (L[I-1] < L[I]) and (L[I+1] <= L[I]) then
    begin
      Open := True;
      FirstNum := I;
    end;
    if (L[I+1] < L[I]) and Open then
    begin
      Open := False;
      Result.Add(Trunc((FirstNum+I)/2));
    end;
    I += 1;
  end;

  if AddLast then
    Result.Add(LastValue);

end;


function IntListToZero(L : TIntList): TIntList;
var
  I, Minimal : Integer;
begin
  Minimal := IntListMin(L);
  Result := TIntList.Create();
  for I := 0 to L.Count-1 do
    Result.Add(Trunc(L.Items[I] + Minimal));
end;

function ResizeIntList(L : TIntList; M : Integer): TIntList;
var
  I, Maximal : Integer;
begin
  Maximal := IntListMax(L);
  Result := TIntList.Create();
  for I := 0 to L.Count-1 do
    Result.Add(Trunc(L.Items[I] / Maximal * M));
end;      

function PlatoToIntList(L : TIntList; Start, Finish, Adder : Integer): TIntList;
var
  I : Integer;
begin
  Result := TIntList.Create();
  for I := 0 to L.Count-1 do
  begin
    if (I > Start) and (I < Finish) then
      Result.Add(L.Items[I]+Adder)
    else  
      Result.Add(L.Items[I]);
  end;
end;

function AddRandToIntList(L : TIntList; Adder : Integer): TIntList;
var
  I : Integer;
begin
  Result := TIntList.Create();
  for I := 0 to L.Count-1 do
    Result.Add(L.Items[I] + Random(Adder));
end;

procedure PrintIntList(L : TIntList);
var
  I : Integer;
begin
  for I := 0 to L.Count-1 do
    Write(L.Items[I], ' ');
  WriteLn;
end;

procedure ShowAll(L : TIntList);
var
  I : Integer;
begin
  for I := 0 to L.Count-1 do
    Write(L.Items[I], ' ');
  WriteLn;
end;

procedure ShowAll(C : Coord3D);
var
  I : Integer;
begin
  if C.Xs.Count = 0 then
    Exit;
  for I := 0 to C.Xs.Count-1 do
    Write('(', C.Xs[I], ', ', C.Ys[I], ', ', C.Zs[I], ')', ', ');
  WriteLn;
end;

function RandFromStrList(StrList : TStrList): String;
begin
  Result := StrList.Items[Random(StrList.Count)];
end;

procedure PrintVector3List(L : TVector3List);
var
  I : Integer;
begin
  If L.Count = 0 then
    Exit;
  for I := 0 to L.Count-1 do
    WriteLn('(', Floor(L[i].X), ',', Floor(L[i].Y), ',', Floor(L[i].Z), ')');
  WriteLn;
end;
{
function IsIn(L : TIntList; X : Integer): Boolean;
var
  I : Integer;
begin
  Result := True;
  for I := 0 to L.Count-1 do
    if L[I] = X then
      Break
    else
    if I = L.Count-1 then
      Result := False;
end;
}

function IsIn(C : Coord2D; X, Y : Integer): Char;
var
  I, J : Integer;
begin
  Result := 'N';
  for I := 0 to C.Xs.Count-1 do
    for J := 0 to C.Ys.Count-1 do
      if (C.Xs[I] = X) and (Y = C.Ys[I]) then
      begin
        Result := 'Y';
        Exit
      end;
end;

function IsIn(C : Coord3D; X, Y : Integer): Char;
var
  I : Integer;
begin
  Result := 'N';
  for I := 0 to C.Xs.Count-1 do
    if (C.Xs[I] = X) and (Y >= C.Ys[I]) and (Y = C.Zs[I]) then
    begin
      Result := 'T';
      Exit
    end
    else if (C.Xs[I] = X) and (Y > C.Ys[I]) and (Y < C.Zs[I]) then
    begin
      Result := 'C';
      Exit;
    end
    else if (C.Xs[I] = X) and (Y = C.Ys[I]) and (Y < C.Zs[I]) then
    begin
      Result := 'B';
      Exit;
    end;
end;

procedure AddToEnd(L : TIntList; X : Integer); overload;
begin
  L.Add(X);
end;

procedure AddToEnd(C : Coord3D; X, Y, Z : Integer); overload;
begin
  C.Xs.Add(X);
  C.Ys.Add(Y);
  C.Zs.Add(Z);
end;

procedure AddToEnd(C : Coord2D; X, Y : Integer); overload;
begin
  C.Xs.Add(X);
  C.Ys.Add(Y);
end;
{
procedure AddLayer(C : Coord3D); overload;
var
  I : Integer;
begin
  for I := 0 to C.Ys.Count do
  begin;
    C.Xs.Add(X);
    C.Ys.Add(Y);
    C.Zs.Add(Z);
  end;
end;
}
procedure AddToStart(C : Coord3D; X, Y, Z : Integer); overload;
begin
  C.Xs.Insert(0, X);
  C.Ys.Insert(0, Y);
  C.Zs.Insert(0, Z);
end;

end.

