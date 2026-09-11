/*
 * Copyright 2025, Polytechnique Montreal and contributors
 *
 * This file is licensed under the MIT License.
 * License text available at https://opensource.org/licenses/MIT
 */

type ProjectConfigModule = {
    configureProject?: () => void;
};

export const loadProjectConfig = (modulePath: string) => {
    if (typeof modulePath !== 'string' || modulePath.length === 0) {
        throw new TypeError('The project configuration module path must be a non-empty string');
    }

    const configModule = require(modulePath) as ProjectConfigModule;
    if (typeof configModule.configureProject !== 'function') {
        throw new Error(`The project configuration module does not export configureProject: ${modulePath}`);
    }

    configModule.configureProject();
};
