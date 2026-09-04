
mreg_recon_path = which('mreg_recon_tool');
mreg_recon_path = [fileparts(mreg_recon_path) filesep '..' filesep];

additional_files = {
    [mreg_recon_path '@finiteDifferenceOperator' filesep 'finiteDifferenceOperator.m'],
    [mreg_recon_path '@identityOperator' filesep 'identityOperator.m'],
    [mreg_recon_path '@nuFTOperator' filesep 'nuFTOperator.m'],
    [mreg_recon_path '@orc_segm_nuFTOperator' filesep 'orc_segm_nuFTOperator.m'],
    [mreg_recon_path '@virtualMatrix' filesep 'virtualMatrix.m'],
    [mreg_recon_path '@waveletDecompositionOperator' filesep 'waveletDecompositionOperator.m'],
};

compiler.build.standaloneApplication("mreg_recon_tool_recon.m", 'AdditionalFiles', additional_files)
