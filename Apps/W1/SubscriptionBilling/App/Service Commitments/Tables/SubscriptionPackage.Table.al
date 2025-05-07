namespace Microsoft.SubscriptionBilling;

using Microsoft.Sales.Pricing;

table 8055 "Subscription Package"
{
    Caption = 'Subscription Package';
    DataClassification = CustomerContent;
    DrillDownPageId = "Service Commitment Packages";
    LookupPageId = "Service Commitment Packages";

    fields
    {
        field(1; Code; Code[20])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(2; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(3; "Price Group"; Code[10])
        {
            Caption = 'Price Group';
            TableRelation = "Customer Price Group";
            trigger OnValidate()
            begin
                UpdateItemServiceCommitments();
            end;
        }
        field(4; Selected; Boolean)
        {
            Caption = 'Selected';
        }
    }
    keys
    {
        key(PK; Code)
        {
            Clustered = true;
        }
    }

    trigger OnDelete()
    var
        ServiceCommPackageLine: Record "Subscription Package Line";
        ItemServCommitmentPackage: Record "Item Subscription Package";
    begin
        ServiceCommPackageLine.SetRange("Subscription Package Code", Code);
        ServiceCommPackageLine.DeleteAll(false);
        ItemServCommitmentPackage.SetRange(Code, Code);
        ItemServCommitmentPackage.DeleteAll(false);
    end;

    local procedure UpdateItemServiceCommitments()
    var
        ItemServiceCommitmentPackage: Record "Item Subscription Package";
    begin
        if not (Rec."Price Group" <> xRec."Price Group") then
            exit;
        ItemServiceCommitmentPackage.SetRange(Code, Rec.Code);
        ItemServiceCommitmentPackage.ModifyAll("Price Group", Rec."Price Group", false);
    end;

    local procedure IsCodeInCopyFormat(NewCode: Code[20]): Boolean
    var
        Position: Integer;
        NewCodeSuffix: Text;
    begin
        NewCodeSuffix := NewCode;
        while StrPos(NewCodeSuffix, '-') > 0 do
            NewCodeSuffix := CopyStr(NewCodeSuffix, StrPos(NewCodeSuffix, '-') + 1);

        repeat
            Position += 1;
            if not IsNumeric(CopyStr(NewCodeSuffix, Position, 1)) then
                exit(false);
        until Position = StrLen(NewCodeSuffix);

        exit(true);
    end;

    internal procedure CopyServiceCommitmentPackage()
    var
        ServiceCommitmentPackage: Record "Subscription Package";
        FromServiceCommitmentPackageLines: Record "Subscription Package Line";
        ToServiceCommitmentPackageLines: Record "Subscription Package Line";
        NewCode: Code[20];
        PackageFilter: Text;
    begin
        if Rec.Code = '' then
            exit;

        NewCode := Rec.Code;
        CreateNewCodeForServiceCommPackageCopy(NewCode);

        ServiceCommitmentPackage := Rec;
        ServiceCommitmentPackage.Code := NewCode;
        if StrPos(Rec.Description, CopyTxt) = 0 then
            ServiceCommitmentPackage.Description := CopyStr(Rec.Description, 1, MaxStrLen(Rec.Description) - StrLen(CopyTxt)) + CopyTxt
        else
            ServiceCommitmentPackage.Description := Rec.Description;

        ServiceCommitmentPackage.Insert(false);

        PackageFilter := Rec.Code;
        TextManagement.ReplaceInvalidFilterChar(PackageFilter);
        FromServiceCommitmentPackageLines.SetFilter("Subscription Package Code", PackageFilter);
        if FromServiceCommitmentPackageLines.FindSet() then
            repeat
                ToServiceCommitmentPackageLines := FromServiceCommitmentPackageLines;
                ToServiceCommitmentPackageLines."Subscription Package Code" := NewCode;
                ToServiceCommitmentPackageLines.Insert(false);
            until FromServiceCommitmentPackageLines.Next() = 0;
    end;

    internal procedure CreateNewCodeForServiceCommPackageCopy(var NewCode: Code[20])
    var
        ServiceCommitmentPackage: Record "Subscription Package";
        OldCode: Code[20];
    begin
        OldCode := NewCode;
        if IsCodeInCopyFormat(NewCode) then
            NewCode := IncStr(NewCode);
        if ((NewCode = '') or (NewCode = OldCode)) then
            NewCode := CopyStr(OldCode, 1, MaxStrLen(NewCode) - 2) + '-1';

        while ServiceCommitmentPackage.Get(NewCode) do
            CreateNewCodeForServiceCommPackageCopy(NewCode);
    end;

    local procedure IsNumeric(Input: Text): Boolean
    begin
        exit(Input in ['0' .. '9']);
    end;

    internal procedure FilterCodeOnPackageFilter(PackageFilter: Text)
    begin
        if PackageFilter = '' then
            Rec.SetRange(Code, '')
        else
            Rec.SetFilter(Code, PackageFilter);
    end;

    internal procedure PackageLineInvoicedViaContractWithoutInvoicingItemExist(): Boolean
    var
        SubscriptionPackageLine: Record "Subscription Package Line";
    begin
        SubscriptionPackageLine.SetRange("Subscription Package Code", Rec.Code);
        SubscriptionPackageLine.SetRange("Invoicing via", Enum::"Invoicing Via"::Contract);
        SubscriptionPackageLine.SetRange("Invoicing Item No.", '');
        exit(not SubscriptionPackageLine.IsEmpty());
    end;

    internal procedure ServCommPackageLineExists(): Boolean
    var
        SubscriptionPackageLine: Record "Subscription Package Line";
    begin
        SubscriptionPackageLine.SetRange("Subscription Package Code", Rec.Code);
        SubscriptionPackageLine.SetRange("Usage Based Billing", true);
        exit(not SubscriptionPackageLine.IsEmpty());
    end;

    var
        TextManagement: Codeunit "Text Management";
        CopyTxt: Label ' (Copy)';
}