codeunit 11801 "Upgrade Mig Local App 18x"
{
    trigger OnRun()
    begin
    end;

    var

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"W1 Company Handler", 'OnUpgradePerCompanyDataForVersion', '', false, false)]
    local procedure OnUpgradePerCompanyDataUpgrade(HybridReplicationSummary: Record "Hybrid Replication Summary"; CountryCode: Text; TargetVersion: Decimal)
    begin
        if TargetVersion <> 18.0 then
            exit;

        UpdateVendorTemplate();
    end;

    local procedure UpdateVendorTemplate()
    var
        VendorTemplate: Record "Vendor Template";
        VendorTempl: Record "Vendor Templ.";
        SourceDefaultDimension: Record "Default Dimension";
        DestDefaultDimension: Record "Default Dimension";
    begin
        if VendorTemplate.FindSet() then
            repeat
                if not VendorTempl.Get(VendorTemplate.Code) then begin
                    VendorTempl.Init();
                    VendorTempl.Code := VendorTemplate.Code;
                    VendorTempl.Description := VendorTemplate.Description;
                    VendorTempl."Global Dimension 1 Code" := VendorTemplate."Global Dimension 1 Code";
                    VendorTempl."Global Dimension 2 Code" := VendorTemplate."Global Dimension 2 Code";
                    VendorTempl."Vendor Posting Group" := VendorTemplate."Vendor Posting Group";
                    VendorTempl."Currency Code" := VendorTemplate."Currency Code";
                    VendorTempl."Language Code" := VendorTemplate."Language Code";
                    VendorTempl."Payment Terms Code" := VendorTemplate."Payment Terms Code";
                    VendorTempl."Invoice Disc. Code" := VendorTemplate."Invoice Disc. Code";
                    VendorTempl."Country/Region Code" := VendorTemplate."Country/Region Code";
                    VendorTempl."Payment Method Code" := VendorTemplate."Payment Method Code";
                    VendorTempl."Gen. Bus. Posting Group" := VendorTemplate."Gen. Bus. Posting Group";
                    VendorTempl."VAT Bus. Posting Group" := VendorTemplate."VAT Bus. Posting Group";
                    VendorTempl.Insert(true);

                    DestDefaultDimension.SetRange("Table ID", Database::"Vendor Templ.");
                    DestDefaultDimension.SetRange("No.", VendorTempl.Code);
                    DestDefaultDimension.DeleteAll(true);

                    SourceDefaultDimension.SetRange("Table ID", Database::"Vendor Template");
                    SourceDefaultDimension.SetRange("No.", VendorTemplate.Code);
                    if SourceDefaultDimension.FindSet() then
                        repeat
                            DestDefaultDimension.Init();
                            DestDefaultDimension.Validate("Table ID", Database::"Vendor Templ.");
                            DestDefaultDimension.Validate("No.", VendorTempl.Code);
                            DestDefaultDimension.Validate("Dimension Code", SourceDefaultDimension."Dimension Code");
                            DestDefaultDimension.Validate("Dimension Value Code", SourceDefaultDimension."Dimension Value Code");
                            DestDefaultDimension.Validate("Value Posting", SourceDefaultDimension."Value Posting");
                            if DestDefaultDimension.Insert(true) then;
                        until SourceDefaultDimension.Next() = 0;
                end;
            until VendorTemplate.Next() = 0;
    end;
}

