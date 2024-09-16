namespace Microsoft.SubscriptionBilling;

using Microsoft.Sales.Pricing;

table 8055 "Service Commitment Package"
{
    Caption = 'Service Commitment Package';
    DataClassification = CustomerContent;
    DrillDownPageId = "Service Commitment Packages";
    LookupPageId = "Service Commitment Packages";
    Access = Internal;

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
        ServiceCommPackageLine: Record "Service Comm. Package Line";
        ItemServCommitmentPackage: Record "Item Serv. Commitment Package";
    begin
        ServiceCommPackageLine.SetRange("Package Code", Code);
        ServiceCommPackageLine.DeleteAll(false);
        ItemServCommitmentPackage.SetRange(Code, Code);
        ItemServCommitmentPackage.DeleteAll(false);
    end;

    local procedure UpdateItemServiceCommitments()
    var
        ItemServiceCommitmentPackage: Record "Item Serv. Commitment Package";
    begin
        if not (Rec."Price Group" <> xRec."Price Group") then
            exit;
        ItemServiceCommitmentPackage.SetRange(Code, Rec.Code);
        ItemServiceCommitmentPackage.ModifyAll("Price Group", Rec."Price Group", false);
    end;

    local procedure IsCodeInCopyFormat(NewCode: Code[20]): Boolean
    var
        Position: Integer;
        NewCodeSufix: Text;
    begin
        NewCodeSufix := NewCode;
        while StrPos(NewCodeSufix, '-') > 0 do
            NewCodeSufix := CopyStr(NewCodeSufix, StrPos(NewCodeSufix, '-') + 1);

        repeat
            Position += 1;
            if not IsNumeric(CopyStr(NewCodeSufix, Position, 1)) then
                exit(false);
        until Position = StrLen(NewCodeSufix);

        exit(true);
    end;

    internal procedure CopyServiceCommitmentPackage()
    var
        ServiceCommitmentPackage: Record "Service Commitment Package";
        FromServiceCommitmentPackageLines: Record "Service Comm. Package Line";
        ToServiceCommitmentPackageLines: Record "Service Comm. Package Line";
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
        FromServiceCommitmentPackageLines.SetFilter("Package Code", PackageFilter);
        if FromServiceCommitmentPackageLines.FindSet() then
            repeat
                ToServiceCommitmentPackageLines := FromServiceCommitmentPackageLines;
                ToServiceCommitmentPackageLines."Package Code" := NewCode;
                ToServiceCommitmentPackageLines.Insert(false);
            until FromServiceCommitmentPackageLines.Next() = 0;
    end;

    internal procedure CreateNewCodeForServiceCommPackageCopy(var NewCode: Code[20])
    var
        ServiceCommitmentPackage: Record "Service Commitment Package";
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

    internal procedure IsNumeric(Input: Text): Boolean
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

    var
        TextManagement: Codeunit "Text Management";
        CopyTxt: Label ' (Copy)';
}