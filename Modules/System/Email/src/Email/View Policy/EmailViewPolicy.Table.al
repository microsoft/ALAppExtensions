// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Contains what policy each user is given in the system
/// </summary>
table 8930 "Email View Policy"
{
    Access = Internal;
    Extensible = false;

    fields
    {
        /// <summary>
        /// Security id of user
        /// </summary>
        field(1; "User Security ID"; Guid)
        {
            DataClassification = SystemMetadata;
        }
        /// <summary>
        /// Name of user
        /// </summary>
        field(2; "User ID"; Code[50])
        {
            Caption = 'User ID';
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = User."User Name";
            ValidateTableRelation = false;

            trigger OnValidate()
            var
                User: Record User;
                UserSelection: Codeunit "User Selection";
                UserEmailPolicy: Codeunit "Email View Policy";
            begin
                if "User ID" = UserEmailPolicy.GetDefaultUserId() then
                    exit;

                UserSelection.ValidateUserName("User ID");
                User.SetRange("User Name", "User ID");
                User.FindFirst();
                "User Security ID" := User."User Security ID";
            end;
        }
        /// <summary>
        /// Policy that user is given
        /// </summary>
        field(3; "Email View Policy"; Enum "Email View Policy")
        {
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(PK; "User Security ID")
        {
            Clustered = true;
        }
        key(K2; "User ID")
        {

        }
    }

}