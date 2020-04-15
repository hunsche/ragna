unit Ragna.Criteria.Impl;

interface

uses FireDAC.Comp.Client, StrUtils, Data.DB, FireDAC.Stan.Param, System.Hash, Ragna.Criteria.Intf, Ragna.Types;

type
  TDefaultCriteria = class(TInterfacedObject, ICriteria)
  private
    FQuery: TFDQuery;
  public
    procedure Where(AField: string); overload;
    procedure Where(AField: TField); overload;
    procedure Where(AValue: Boolean); overload;
    procedure &Or(AField: string); overload;
    procedure &Or(AField: TField); overload;
    procedure &And(AField: string); overload;
    procedure &And(AField: TField); overload;
    procedure Like(AValue: string);
    procedure &Equals(AValue: Int64); overload;
    procedure &Equals(AValue: Boolean); overload;
    procedure &Equals(AValue: string); overload;
    procedure Order(AField: TField);
    constructor Create(AQuery: TFDQuery);
  end;

  TManagerCriteria = class
  private
    FCriteria: ICriteria;
    function GetDrive(AQuery: TFDQuery): string;
    function GetInstanceCriteria(AQuery: TFDQuery): ICriteria;
  public
    constructor Create(AQuery: TFDQuery);
    property Criteria: ICriteria read FCriteria write FCriteria;
  end;

implementation

uses FireDAC.Stan.Intf, SysUtils;

procedure TDefaultCriteria.&And(AField: string);
const
  PHRASE = ' %s %s';
begin
  FQuery.SQL.Add(Format(PHRASE, [otAnd.ToString, AField]));
end;

procedure TDefaultCriteria.&And(AField: TField);
const
  PHRASE = ' %s %s';
begin
  FQuery.SQL.Add(Format(PHRASE, [otAnd.ToString, AField.Origin]));
end;

procedure TDefaultCriteria.&Or(AField: string);
const
  PHRASE = ' %s %s';
begin
  FQuery.SQL.Add(Format(PHRASE, [otOr.ToString, AField]));
end;

constructor TDefaultCriteria.Create(AQuery: TFDQuery);
begin
  FQuery := AQuery;
end;

procedure TDefaultCriteria.Equals(AValue: string);
const
  PHRASE = '%s ''%s''';
begin
  FQuery.SQL.Add(Format(PHRASE, [otEquals.ToString, AValue]));
end;

procedure TDefaultCriteria.Equals(AValue: Int64);
const
  PHRASE = '%s %d';
begin
  FQuery.SQL.Add(Format(PHRASE, [otEquals.ToString, AValue]));
end;

procedure TDefaultCriteria.Where(AField: TField);
const
  PHRASE = '%s %s';
begin
  FQuery.SQL.Add(Format(PHRASE, [otWhere.ToString, AField.Origin]));
end;

procedure TDefaultCriteria.Equals(AValue: Boolean);
const
  PHRASE = '%s %s';
begin
  FQuery.SQL.Add(Format(PHRASE, [otEquals.ToString, BoolToStr(AValue, True)]));
end;

procedure TDefaultCriteria.Like(AValue: string);
const
  PHRASE = '::text %s %s';
var
  LKeyParam: string;
  LParam: TFDParam;
begin
  LKeyParam := THashMD5.Create.HashAsString;
  FQuery.SQL.Text := FQuery.SQL.Text + Format(PHRASE, [otLike.ToString, ':' + LKeyParam]);
  LParam := FQuery.ParamByName(LKeyParam);
  LParam.DataType := ftString;
  LParam.Value := AValue;
end;

procedure TDefaultCriteria.Order(AField: TField);
const
  PHRASE = '%s %s';
begin
  FQuery.SQL.Add(Format(PHRASE, [otOrder.ToString, AField.Origin]));
end;

procedure TDefaultCriteria.Where(AField: string);
const
  PHRASE = '%s %s';
begin
  FQuery.SQL.Add(Format(PHRASE, [otWhere.ToString, AField]));
end;

procedure TDefaultCriteria.Where(AValue: Boolean);
const
  PHRASE = '%s %s';
begin
  FQuery.SQL.Add(Format(PHRASE, [otWhere.ToString, BoolToStr(AValue, True)]));
end;

procedure TDefaultCriteria.&Or(AField: TField);
const
  PHRASE = ' %s %s';
begin
  FQuery.SQL.Add(Format(PHRASE, [otOr.ToString, AField.Origin]));
end;

constructor TManagerCriteria.Create(AQuery: TFDQuery);
begin
  FCriteria := GetInstanceCriteria(AQuery);
end;

function TManagerCriteria.GetDrive(AQuery: TFDQuery): string;
var
  LDef: IFDStanConnectionDef;
begin
  Result := AQuery.Connection.DriverName;
  if Result.IsEmpty and not AQuery.Connection.ConnectionDefName.IsEmpty then
  begin
    LDef := FDManager.ConnectionDefs.FindConnectionDef(AQuery.Connection.ConnectionDefName);
    if LDef = nil then
      raise Exception.Create('ConnectionDefs "' + AQuery.Connection.ConnectionDefName + '" not found');
    Result := LDef.Params.DriverID;
  end;
end;

function TManagerCriteria.GetInstanceCriteria(AQuery: TFDQuery): ICriteria;
begin
  case AnsiIndexStr(GetDrive(AQuery), ['PG']) of
    0:
      Result := TDefaultCriteria.Create(AQuery);
    else
      Result := TDefaultCriteria.Create(AQuery);
  end;
end;

end.
