codeunit 5300 "Create Online Map Para. Setup"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoEServices: Codeunit "Contoso eServices";
    begin
        ContosoEServices.InsertEServiceOnlineMapParameter(OnlineMapParameter(), OnlineMapParameterNameLbl, OnlineMapParaMeterServiceNameLbl, OnlineMapParaMeterServiceDirectionServiceLbl, OnlineMapParameterCommentLbl, false, '', '0,1', OnlineMapParaMeterDiresctionFromLOcationServiceLbl);
    end;

    procedure OnlineMapParameter(): Code[10]
    begin
        exit(OnlineMapParameterLbl);
    end;

    var
        OnlineMapParameterLbl: Label 'BING', MaxLength = 10, Locked = true;
        OnlineMapParameterNameLbl: Label 'Bing Maps', MaxLength = 30, Locked = true;
        OnlineMapParaMeterServiceNameLbl: Label 'https://bing.com/maps/default.aspx?where1={1}+{2}+{6}&v=2&mkt={7}', MaxLength = 250, Locked = true;
        OnlineMapParaMeterServiceDirectionServiceLbl: Label 'https://bing.com/maps/default.aspx?rtp=adr.{1}+{2}+{6}~adr.{1}+{2}+{6}&v=2&mkt={7}&rtop={9}~0~0', MaxLength = 250, Locked = true;
        OnlineMapParameterCommentLbl: Label 'http://go.microsoft.com/fwlink/?LinkId=519372', MaxLength = 250, Locked = true;
        OnlineMapParaMeterDiresctionFromLOcationServiceLbl: Label 'https://bing.com/maps/default.aspx?rtp=pos.{10}_{11}~adr.{1}+{2}+{6}&v=2&mkt={7}&rtop={9}~0~0', MaxLength = 250, Locked = true;
}