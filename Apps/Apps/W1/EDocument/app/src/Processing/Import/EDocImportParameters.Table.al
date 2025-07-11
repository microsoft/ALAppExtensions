// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.EServices.EDocument.Processing.Import;

/// <summary>
/// Parameters to configure how an E-Document is taken to a different state of the import process. This is used by the entry point "E-Doc. Import" ProcessIncomingDocument and it influences how the E-Document is processed.
/// </summary>
table 6106 "E-Doc. Import Parameters"
{
    TableType = Temporary;

    fields
    {
        /// <summary>
        /// Any of the supported customizations to the processing can be overwritten here to change the defaults
        /// </summary>
        field(2; "Processing Customizations"; Enum "E-Doc. Proc. Customizations")
        {
        }

        /// <summary>
        /// Whether the processing is specified by the final step to be run, or by the desired final status of the E-Document.
        /// If the final step is specified, the processing will run until that step is executed, if the step has already been executed, it will undo the step and run it again.
        /// This is used together with the "Step to Run" field, which specifies the final step to run.
        /// 
        /// If the desired status is specified, the processing will run until the E-Document reaches that status (even if it requires undoing some steps).
        /// This is used together with the "Desired E-Document Status" field, which specifies the final status to reach.
        /// </summary>
        field(5; "Step to Run / Desired Status"; Option)
        {
            OptionMembers = "Step to Run","Desired E-Document Status";
        }

        /// <summary>
        /// Specifies the final step to run in the import process. If the step has already been executed, it will undo the step and run it again.
        /// </summary>
        field(1; "Step to Run"; Enum "Import E-Document Steps")
        {
        }

        /// <summary>
        /// Specifies the desired final status of the E-Document after processing.
        /// </summary>
        field(6; "Desired E-Document Status"; Enum "Import E-Doc. Proc. Status")
        {
        }

        #region E-Document import processing V1 parameters
        field(3; "Purch. Journal V1 Behavior"; Option)
        {
            OptionMembers = "Inherit from service","Create purchase document","Create journal line";
        }
        field(4; "Create Document V1 Behavior"; Boolean)
        {
        }
        #endregion
    }
}