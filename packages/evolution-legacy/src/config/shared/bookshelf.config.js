/*
 * Copyright 2023, Polytechnique Montreal and contributors
 *
 * This file is licensed under the MIT License.
 * License text available at https://opensource.org/licenses/MIT
 */
// TODO This file should not be necessary
const knex        = require('chaire-lib-backend/lib/config/shared/db.config').default;
const jsonColumns = require('bookshelf-json-columns');
const bookShelf   = require('bookshelf')(knex).plugin(jsonColumns);
module.exports = bookShelf;