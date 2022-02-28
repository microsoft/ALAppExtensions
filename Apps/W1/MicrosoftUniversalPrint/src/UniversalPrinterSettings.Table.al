// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Provides functionality to manage configuration for Universal Printers.
/// </summary>
table 2751 "Universal Printer Settings"
{
    fields
    {
        /// <summary>
        /// The unique name of the printer settings.
        /// </summary>
        field(1; Name; code[250])
        {
            Caption = 'Name';
            NotBlank = true;
        }

        /// <summary>
        /// The identifier of the print share assocated with the printer settings.
        /// </summary>
        field(2; "Print Share ID"; Guid)
        {
            Caption = 'Print Share ID';
            NotBlank = true;
        }

        /// <summary>
        /// The name of the print share associated with the printer settings.
        /// </summary>
        field(3; "Print Share Name"; Text[2048])
        {
            Caption = 'Print Share Name';
            NotBlank = true;
        }

        /// <summary>
        /// The description of the printer.
        /// </summary>
        field(5; Description; Text[250])
        {
            Caption = 'Description';
        }

        /// <summary>
        /// The media (paper) size of the printer.
        /// </summary>
        field(6; "Paper Size"; Enum "Printer Paper Kind")
        {
            Caption = 'Paper Size';
        }

        /// <summary>
        /// The height of the paper.
        /// </summary>
        field(8; "Paper Height"; Decimal)
        {
            Caption = 'Printer Paper Height';
            DecimalPlaces = 0 : 2;
        }

        /// <summary>
        /// The width of the paper.
        /// </summary>
        field(9; "Paper Width"; Decimal)
        {
            Caption = 'Printer Paper Width';
            DecimalPlaces = 0 : 2;
        }

        /// <summary>
        /// The unit of the paper measurements.
        /// </summary>
        field(10; "Paper Unit"; Enum "Universal Printer Paper Unit")
        {
            Caption = 'Printer Paper Units';
        }

        /// <summary>
        /// The value indicating landscape paper orientation.
        /// </summary>
        field(11; Landscape; Boolean)
        {
            Caption = 'Landscape';
        }

        /// <summary>
        /// The value indicating if printing is allowed for all the users.
        /// </summary>
        field(18; AllowAllUsers; Boolean)
        {
            Caption = 'Allow all users';
        }

        /// <summary>
        /// The output bin to use when printing the document.
        /// </summary>
        field(12; outputBin; Text[2048])
        {
            Caption = 'Output Bin';
#if not CLEAN18
            ObsoleteState = Pending;
            ObsoleteTag = '18.0';
#else
            ObsoleteState = Removed;
            ObsoleteTag = '21.0';
#endif
            ObsoleteReason = 'Replaced with Paper Tray';
        }

        /// <summary>
        /// The output paper tray to use when printing the document.
        /// </summary>
        field(13; "Paper Tray"; Text[2048])
        {
            Caption = 'Paper Tray';
        }
    }

    keys
    {
        key(PrimaryKey; Name)
        {
            Clustered = true;
        }
        key(Key2; "Print Share ID")
        {
        }
    }
}