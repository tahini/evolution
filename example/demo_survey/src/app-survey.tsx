import runClientApp from 'evolution-legacy/lib/app-survey';
import { SurveyAppConfig } from './config/application.config';
import { setApplicationConfiguration } from 'chaire-lib-frontend/lib/config/application.config';

import surveySections from './survey/sections';
import * as widgetsConfig from './survey/widgets';
import projectHelpers from './survey/helper';

let validations = undefined;
let parsers = undefined;

// TODO Let there be an admin config that can be loaded only for the admin application, to avoid using require for the admin settings.
setApplicationConfiguration<SurveyAppConfig>({
    sections: surveySections,
    widgets: widgetsConfig,
    getAdminValidations: () => {
        if (validations === undefined) {
            validations = require(`./admin/validations.js`).default;
        }
        return validations;
    },
    projectHelpers,
    getParsers: () => {
        if (parsers === undefined) {
            parsers = require(`./admin/parsers.js`).default;
        }
        return parsers;
    }
});

runClientApp();