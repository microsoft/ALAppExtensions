namespace Microsoft.SubscriptionBilling;

codeunit 8027 "Process Usage Data Import"
{
    Access = Internal;
    TableNo = "Usage Data Import";

    trigger OnRun()
    begin
        UsageDataImport.Copy(Rec);
        Code();
        Rec := UsageDataImport;
    end;

    local procedure Code()
    var
        UsageDataSupplier: Record "Usage Data Supplier";
    begin
        UsageDataImport.SetFilter("Processing Status", '<>%1', Enum::"Processing Status"::Closed);
        if UsageDataImport.FindSet() then
            repeat
                UsageDataSupplier.Get(UsageDataImport."Supplier No.");
                UsageDataImport."Processing Status" := Enum::"Processing Status"::None;
                if Codeunit.Run(Codeunit::"Generic Usage Data Import", UsageDataImport) then begin
                    if UsageDataImport."Processing Status" <> Enum::"Processing Status"::Error then
                        UsageDataImport.Validate("Processing Status", Enum::"Processing Status"::Ok);
                end else begin
                    UsageDataImport.Validate("Processing Status", Enum::"Processing Status"::Error);
                    UsageDataImport.SetReason(GetLastErrorText);
                end;
                UsageDataImport.Modify(false);
            until UsageDataImport.Next() = 0;
    end;

    var
        UsageDataImport: Record "Usage Data Import";
}
