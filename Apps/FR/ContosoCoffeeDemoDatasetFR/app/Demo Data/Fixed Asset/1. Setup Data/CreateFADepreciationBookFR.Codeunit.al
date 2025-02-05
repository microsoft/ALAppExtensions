codeunit 10875 "Create FA Depreciation Book FR"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoFixedAsset: Codeunit "Contoso Fixed Asset";
    begin
        ContosoFixedAsset.InsertDepreciationBook(Tax(), DerogatoryBookLbl, false, false, false, false, false, false, false, false, false, 0);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Depreciation Book", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertDepreciationBook(var Rec: Record "Depreciation Book")
    var
        CreateFADeprBook: Codeunit "Create FA Depreciation Book";
    begin
        case Rec.Code of
            CreateFADeprBook.Company():
                ValidateDepreciationBook(Rec, CompanyDescLbl, Rec."Disposal Calculation Method"::Gross, false, true);
            Tax():
                ValidateFADepreciationBook(Rec, Rec."Disposal Calculation Method"::Gross, CreateFADeprBook.Company());
        end;
    end;

    local procedure ValidateDepreciationBook(var DepreciationBook: Record "Depreciation Book"; DepreciationDesc: Text[100]; DisposalCalc: Option; UseRoundingInPerodic: Boolean; GLIntegrationDerogatory: Boolean)
    begin
        DepreciationBook.Validate(Description, DepreciationDesc);
        DepreciationBook.Validate("Disposal Calculation Method", DisposalCalc);
        DepreciationBook.Validate("Use Rounding in Periodic Depr.", UseRoundingInPerodic);
        DepreciationBook.Validate("G/L Integration - Derogatory", GLIntegrationDerogatory);
    end;

    local procedure ValidateFADepreciationBook(var DepreciationBook: Record "Depreciation Book"; DisposalCalc: Option; DerogatoryCalc: Code[10])
    begin
        DepreciationBook.Validate("Disposal Calculation Method", DisposalCalc);
        DepreciationBook.Validate("Derogatory Calculation", DerogatoryCalc);
    end;

    var
        TaxTok: Label 'TAX', MaxLength = 10, Locked = true;
        CompanyDescLbl: Label 'Accounting Book', MaxLength = 100;
        DerogatoryBookLbl: Label 'Derogatory Book', MaxLength = 100;

    procedure Tax(): Code[10]
    begin
        exit(TaxTok);
    end;
}