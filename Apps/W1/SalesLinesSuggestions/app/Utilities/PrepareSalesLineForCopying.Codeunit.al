namespace Microsoft.Sales.Document;
codeunit 7290 "Prepare Sales Line For Copying"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;
    trigger OnRun()
    var
    begin
        PrepareSalesLine();
    end;

    local procedure PrepareSalesLine()
    begin
        Clear(TempGlobalPreparedSalesLine);
        TempGlobalPreparedSalesLine.Init();
        TempGlobalPreparedSalesLine."Line No." := GlobalLineNo;
        TempGlobalPreparedSalesLine."Document No." := GlobalSourceSalesHeader."No.";
        TempGlobalPreparedSalesLine."Document Type" := GlobalSourceSalesHeader."Document Type";
        TempGlobalPreparedSalesLine.Type := TempGlobalSalesLineAiSuggestion.Type;
        TempGlobalPreparedSalesLine.Validate("No.", TempGlobalSalesLineAiSuggestion."No.");
        TempGlobalPreparedSalesLine.Validate(Description, TempGlobalSalesLineAiSuggestion.Description);
        if TempGlobalSalesLineAiSuggestion."Variant Code" <> '' then
            TempGlobalPreparedSalesLine.Validate("Variant Code", TempGlobalSalesLineAiSuggestion."Variant Code");
        TempGlobalPreparedSalesLine.Validate(Quantity, TempGlobalSalesLineAiSuggestion.Quantity);
        TempGlobalPreparedSalesLine.Validate("Unit of Measure Code", TempGlobalSalesLineAiSuggestion."Unit of Measure Code");
        TempGlobalPreparedSalesLine.Insert();
    end;

    procedure SetParameters(var SourceSalesHeader: Record "Sales Header"; LineNo: Integer; TempSalesLineAiSuggestion: Record "Sales Line AI Suggestions" temporary)
    begin
        GlobalSourceSalesHeader := SourceSalesHeader;
        GlobalLineNo := LineNo;
        TempGlobalSalesLineAiSuggestion := TempSalesLineAiSuggestion;
    end;

    procedure GetPreparedLine(): Record "Sales Line" temporary
    begin
        exit(TempGlobalPreparedSalesLine);
    end;

    var
        TempGlobalPreparedSalesLine: Record "Sales Line" temporary;
        GlobalSourceSalesHeader: Record "Sales Header";
        TempGlobalSalesLineAiSuggestion: Record "Sales Line AI Suggestions" temporary;
        GlobalLineNo: Integer;
}