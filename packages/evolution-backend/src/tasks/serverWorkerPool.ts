/*
 * Copyright 2024, Polytechnique Montreal and contributors
 *
 * This file is licensed under the MIT License.
 * License text available at https://opensource.org/licenses/MIT
 */
import workerpool, { WorkerPool } from 'workerpool';
import { loadProjectConfig } from '../config/projectConfigLoader';

let pool: WorkerPool | undefined = undefined;
let projectConfigModule: string | undefined = undefined;

/**
 * Set the module that initializes the project-specific server configuration.
 *
 * The module path is passed to the worker through workerData. The module is
 * loaded inside the worker so functions in the configuration are never cloned
 * or serialized between threads.
 */
export const setWorkerProjectConfigModule = (modulePath: string) => {
    if (pool !== undefined) {
        throw new Error('The worker pool has already been started');
    }
    projectConfigModule = modulePath;
};

export const configureProject = (modulePath: string) => {
    loadProjectConfig(modulePath);
    setWorkerProjectConfigModule(modulePath);
};

export const startPool = () => {
    // TODO: Add a server preference for the maximum number of workers
    pool = workerpool.pool(__dirname + '/EvolutionWorkerPool.js', {
        maxWorkers: 1,
        workerType: 'thread',
        workerThreadOpts: {
            workerData: {
                projectConfigModule
            }
        }
    });
};

export const execJob = async (
    ...parameters: Parameters<WorkerPool['exec']>
): Promise<ReturnType<WorkerPool['exec']>> => {
    if (pool === undefined) {
        startPool();
    }
    return pool.exec(...parameters);
};
