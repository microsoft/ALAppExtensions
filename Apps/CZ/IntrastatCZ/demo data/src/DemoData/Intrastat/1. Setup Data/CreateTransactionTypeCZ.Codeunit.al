// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Localization;

using Microsoft.DemoTool.Helpers;

codeunit 31493 "Create Transaction Type CZ"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        ImportFromXml();
        InsertTransactionType();
    end;

    local procedure ImportFromXml()
    begin
        NavApp.GetResource(XmlFileTok, FileInStream);
        ImportTransactionTypesCZ.SetSource(FileInStream);
        ImportTransactionTypesCZ.SetThresholdDate(WorkDate());
        ImportTransactionTypesCZ.Import();
    end;

    local procedure InsertTransactionType()
    var
        ContosoIntrastatCZ: Codeunit "Contoso Intrastat CZ";
    begin
        ContosoIntrastatCZ.InsertTransactionType(Type11(), Type11DescriptionLbl);
        ContosoIntrastatCZ.InsertTransactionType(Type21(), Type21DescriptionLbl);
    end;

    procedure Type11(): Code[10]
    begin
        exit(Type11Tok);
    end;

    procedure Type21(): Code[10]
    begin
        exit(Type21Tok);
    end;

    var
        ImportTransactionTypesCZ: XmlPort "Import Transaction Types CZ";
        FileInStream: InStream;
        XmlFileTok: Label 'trans_i_004.xml', Locked = true;
        Type11Tok: Label '11', Locked = true;
        Type11DescriptionLbl: Label 'Přímý prodej/nákup s výjimkou přímého obchodu se soukromými spotřebiteli/ze stra', MaxLength = 80;
        Type21Tok: Label '21', Locked = true;
        Type21DescriptionLbl: Label 'Vrácení zboží', MaxLength = 80;
}