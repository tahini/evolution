/*
 * Copyright 2022, Polytechnique Montreal and contributors
 *
 * This file is licensed under the MIT License.
 * License text available at https://opensource.org/licenses/MIT
 */
// This file is meant as the entry point of the worker pool, to be run in workers directly
import workerpool from 'workerpool';
import { workerData } from 'worker_threads';
import { loadProjectConfig } from '../config/projectConfigLoader';
import { exportAllToCsvBySurveyObjectTask } from '../services/adminExport/exportAllToCsvBySurveyObject';
import { exportInterviewLogTask } from '../services/adminExport/exportInterviewLogs';
import { runBatchAuditsTask } from '../services/audits/BatchAuditService';

const initializeProjectConfig = () => {
    const projectConfigModule = workerData?.projectConfigModule;
    if (projectConfigModule === undefined) {
        return;
    }

    loadProjectConfig(projectConfigModule);
};

// Worker pool for evolution backend tasks
const run = async () => {
    initializeProjectConfig();

    // create a worker and register public functions
    workerpool.worker({
        exportAllToCsvBySurveyObject: exportAllToCsvBySurveyObjectTask,
        exportInterviewLog: exportInterviewLogTask,
        runBatchAudits: runBatchAuditsTask
    });
};

run();

export default workerpool;
