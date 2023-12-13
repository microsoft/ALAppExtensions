codeunit 4791 "Create Whse Put Away Template"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        STDTok: Label 'STD', Locked = true;
        VARTok: Label 'VAR', Locked = true;
        SAMETok: Label 'SAME', Locked = true;
        STDDescTok: Label 'Standard Template', MaxLength = 100;
        VARDescTok: Label 'Variable Template', MaxLength = 100;
        SAMEDescTok: Label 'Fixed Bins only', MaxLength = 100;

    trigger OnRun()
    var
        ContosoWarehouse: Codeunit "Contoso Warehouse";
    begin
        ContosoWarehouse.InsertPutAwayTemplateHeader(StandardTemplate(), STDDescTok);
        ContosoWarehouse.InsertPutAwayTemplateHeader(VariableTemplate(), VARDescTok);
        ContosoWarehouse.InsertPutAwayTemplateHeader(SameTemplate(), SAMEDescTok);


        ContosoWarehouse.InsertPutAwayTemplateLine(StandardTemplate(), '', true, false, true, true, true, false);
        ContosoWarehouse.InsertPutAwayTemplateLine(StandardTemplate(), '', true, false, true, true, false, false);
        ContosoWarehouse.InsertPutAwayTemplateLine(StandardTemplate(), '', false, true, true, true, false, false);
        ContosoWarehouse.InsertPutAwayTemplateLine(StandardTemplate(), '', false, true, true, false, false, false);
        ContosoWarehouse.InsertPutAwayTemplateLine(StandardTemplate(), '', false, true, false, false, false, true);
        ContosoWarehouse.InsertPutAwayTemplateLine(StandardTemplate(), '', false, true, false, false, false, false);

        ContosoWarehouse.InsertPutAwayTemplateLine(VariableTemplate(), '', false, true, true, true, false, false);
        ContosoWarehouse.InsertPutAwayTemplateLine(VariableTemplate(), '', false, true, false, false, false, true);
        ContosoWarehouse.InsertPutAwayTemplateLine(VariableTemplate(), '', false, true, false, false, false, false);

        ContosoWarehouse.InsertPutAwayTemplateLine(SameTemplate(), '', true, false, true, true, true, false);
        ContosoWarehouse.InsertPutAwayTemplateLine(SameTemplate(), '', true, false, true, true, false, false);
    end;

    procedure StandardTemplate(): Code[10]
    begin
        exit(STDTok);
    end;

    procedure VariableTemplate(): Code[10]
    begin
        exit(VARTok);
    end;

    procedure SameTemplate(): Code[10]
    begin
        exit(SAMETok);
    end;
}
