// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.FixedAsset;

using Microsoft.DemoTool.Helpers;

codeunit 19050 "Create IN Fixed Asset Block"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoINTaxSetup: Codeunit "Contoso IN Tax Setup";
        CreateFAClass: Codeunit "Create FA Class";
    begin
        ContosoINTaxSetup.InsertFixedAssetBlock(CreateFAClass.InTangibleClass(), Block13(), Block13Lbl, 25, 0);
        ContosoINTaxSetup.InsertFixedAssetBlock(CreateFAClass.InTangibleClass(), Block14(), Block14Lbl, 25, 0);
        ContosoINTaxSetup.InsertFixedAssetBlock(CreateFAClass.InTangibleClass(), Block15(), Block15Lbl, 25, 0);
        ContosoINTaxSetup.InsertFixedAssetBlock(CreateFAClass.InTangibleClass(), Block16(), Block16Lbl, 25, 0);
        ContosoINTaxSetup.InsertFixedAssetBlock(CreateFAClass.InTangibleClass(), Block17(), Block17Lbl, 25, 0);
        ContosoINTaxSetup.InsertFixedAssetBlock(CreateFAClass.InTangibleClass(), Block18(), Block18Lbl, 25, 0);
        ContosoINTaxSetup.InsertFixedAssetBlock(CreateFAClass.InTangibleClass(), Block19(), Block19Lbl, 25, 0);
        ContosoINTaxSetup.InsertFixedAssetBlock(CreateFAClass.TangibleClass(), Block01(), Block01Lbl, 5, 0);
        ContosoINTaxSetup.InsertFixedAssetBlock(CreateFAClass.TangibleClass(), Block02(), Block02Lbl, 10, 0);
        ContosoINTaxSetup.InsertFixedAssetBlock(CreateFAClass.TangibleClass(), Block03(), Block03Lbl, 100, 0);
        ContosoINTaxSetup.InsertFixedAssetBlock(CreateFAClass.TangibleClass(), Block04(), Block04Lbl, 10, 0);
        ContosoINTaxSetup.InsertFixedAssetBlock(CreateFAClass.TangibleClass(), Block05(), Block05Lbl, 15, 20);
        ContosoINTaxSetup.InsertFixedAssetBlock(CreateFAClass.TangibleClass(), Block06(), Block06Lbl, 20, 0);
        ContosoINTaxSetup.InsertFixedAssetBlock(CreateFAClass.TangibleClass(), Block07(), Block07Lbl, 30, 0);
        ContosoINTaxSetup.InsertFixedAssetBlock(CreateFAClass.TangibleClass(), Block08(), Block08Lbl, 40, 0);
        ContosoINTaxSetup.InsertFixedAssetBlock(CreateFAClass.TangibleClass(), Block09(), Block09Lbl, 50, 0);
        ContosoINTaxSetup.InsertFixedAssetBlock(CreateFAClass.TangibleClass(), Block10(), Block10Lbl, 60, 0);
        ContosoINTaxSetup.InsertFixedAssetBlock(CreateFAClass.TangibleClass(), Block11(), Block11Lbl, 80, 0);
        ContosoINTaxSetup.InsertFixedAssetBlock(CreateFAClass.TangibleClass(), Block12(), Block12Lbl, 100, 0);
    end;

    procedure Block13(): Code[10]
    begin
        exit(Block13Tok);
    end;

    procedure Block14(): Code[10]
    begin
        exit(Block14Tok);
    end;

    procedure Block15(): Code[10]
    begin
        exit(Block15Tok);
    end;

    procedure Block16(): Code[10]
    begin
        exit(Block16Tok);
    end;

    procedure Block17(): Code[10]
    begin
        exit(Block17Tok);
    end;

    procedure Block18(): Code[10]
    begin
        exit(Block18Tok);
    end;

    procedure Block19(): Code[10]
    begin
        exit(Block19Tok);
    end;

    procedure Block01(): Code[10]
    begin
        exit(Block01Tok);
    end;

    procedure Block02(): Code[10]
    begin
        exit(Block02Tok);
    end;

    procedure Block03(): Code[10]
    begin
        exit(Block03Tok);
    end;

    procedure Block04(): Code[10]
    begin
        exit(Block04Tok);
    end;

    procedure Block05(): Code[10]
    begin
        exit(Block05Tok);
    end;

    procedure Block06(): Code[10]
    begin
        exit(Block06Tok);
    end;

    procedure Block07(): Code[10]
    begin
        exit(Block07Tok);
    end;

    procedure Block08(): Code[10]
    begin
        exit(Block08Tok);
    end;

    procedure Block09(): Code[10]
    begin
        exit(Block09Tok);
    end;

    procedure Block10(): Code[10]
    begin
        exit(Block10Tok);
    end;

    procedure Block11(): Code[10]
    begin
        exit(Block11Tok);
    end;

    procedure Block12(): Code[10]
    begin
        exit(Block12Tok);
    end;

    var
        Block13Tok: Label 'BLOCK 13', MaxLength = 10;
        Block14Tok: Label 'BLOCK 14', MaxLength = 10;
        Block15Tok: Label 'BLOCK 15', MaxLength = 10;
        Block16Tok: Label 'BLOCK 16', MaxLength = 10;
        Block17Tok: Label 'BLOCK 17', MaxLength = 10;
        Block18Tok: Label 'BLOCK 18', MaxLength = 10;
        Block19Tok: Label 'BLOCK 19', MaxLength = 10;
        Block01Tok: Label 'BLOCK 01', MaxLength = 10;
        Block02Tok: Label 'BLOCK 02', MaxLength = 10;
        Block03Tok: Label 'BLOCK 03', MaxLength = 10;
        Block04Tok: Label 'BLOCK 04', MaxLength = 10;
        Block05Tok: Label 'BLOCK 05', MaxLength = 10;
        Block06Tok: Label 'BLOCK 06', MaxLength = 10;
        Block07Tok: Label 'BLOCK 07', MaxLength = 10;
        Block08Tok: Label 'BLOCK 08', MaxLength = 10;
        Block09Tok: Label 'BLOCK 09', MaxLength = 10;
        Block10Tok: Label 'BLOCK 10', MaxLength = 10;
        Block11Tok: Label 'BLOCK 11', MaxLength = 10;
        Block12Tok: Label 'BLOCK 12', MaxLength = 10;
        Block13Lbl: Label 'Know-how', MaxLength = 30;
        Block14Lbl: Label 'Patents', MaxLength = 30;
        Block15Lbl: Label 'Copy rights', MaxLength = 30;
        Block16Lbl: Label 'Trade marks', MaxLength = 30;
        Block17Lbl: Label 'Licences', MaxLength = 30;
        Block18Lbl: Label 'Franchises', MaxLength = 30;
        Block19Lbl: Label 'Other rights', MaxLength = 30;
        Block01Lbl: Label 'Residential buildings', MaxLength = 30;
        Block02Lbl: Label 'Office,Factory,Godowns,Hotels', MaxLength = 30;
        Block03Lbl: Label 'Wooden Structures,', MaxLength = 30;
        Block04Lbl: Label 'Furniture', MaxLength = 30;
        Block05Lbl: Label 'Plant and Machinery', MaxLength = 30;
        Block06Lbl: Label 'Ocean going ships,Vessels', MaxLength = 30;
        Block07Lbl: Label 'Buses,taxies on hire,Lorries', MaxLength = 30;
        Block08Lbl: Label 'Plant and machinery Aeroplanes', MaxLength = 30;
        Block09Lbl: Label 'Containers made of glass', MaxLength = 30;
        Block10Lbl: Label 'Computers including softwares', MaxLength = 30;
        Block11Lbl: Label 'Energy saving devices', MaxLength = 30;
        Block12Lbl: Label 'Air pollution control equipm..', MaxLength = 30;
}
