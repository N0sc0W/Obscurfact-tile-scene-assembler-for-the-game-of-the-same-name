unit Noise;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Math, Generics.Collections,

  FastNoiseLite;

type
  TIntList = specialize TList<Integer>;

  TNoiseState = class
  private
    FNL : FNL_State;
  public
    constructor Create();
    function CircleInt(X, Y, Len, Rad : Integer): TIntList;
  end;

  function SliceIntList(L : TIntList; Start, Finish : Integer): TIntList;
  function IntListMax(L : TIntList): Integer;
  function ResizeIntList(L : TIntList; M : Integer): TIntList;
  procedure PrintIntList(L : TIntList);

implementation

constructor TNoiseState.Create();
begin
  FNL := fnlCreateState();
  FNL.frequency := 0.04;
  FNL.noise_type := FNL_NOISE_OPENSIMPLEX2;
  FNL.cellular_distance_func := FNL_CELLULAR_DISTANCE_EUCLIDEAN;
  FNL.domain_warp_type := FNL_DOMAIN_WARP_OPENSIMPLEX2;
  FNL.domain_warp_amp := 12.0;
  FNL.fractal_type := FNL_FRACTAL_PINGPONG;
  FNL.weighted_strength := 0.8;

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

function SliceIntList(L : TIntList; Start, Finish : Integer): TIntList;
var
  I : Integer;
begin
  if (Start > Finish) or (abs(Start) > (L.Count-1)*2) or (abs(Finish) > (L.Count-1)*2) then
    raise ERangeError.Create('Incorrect index for list');

  Result := TIntList.Create();

  if Start < 0 then
    for I := L.Count+Start to L.Count-1 do
      Result.Add(L[I]);

  for I := max(0, Start) to min(L.Count-1, Finish) do
      Result.Add(L[I]);

  if Finish > L.Count-1 then
    for I := 0 to Finish-L.Count-1 do
      Result.Add(L[I]); ;
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

function ResizeIntList(L : TIntList; M : Integer): TIntList;
var
  I, Maximal : Integer;
begin
  Maximal := IntListMax(L);
  Result := TIntList.Create();
  for I := 0 to L.Count-1 do
    Result.Add(6);
end;

procedure PrintIntList(L : TIntList);
var
  I : Integer;
begin
  for I := 0 to L.Count-1 do
    Write(L.Items[I], ' ');
  WriteLn;
end;

end.

