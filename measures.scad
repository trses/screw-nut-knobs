/**
 * Measures of metric screws and nuts accoring to
 * ISO 4017 / DIN 933 - hexagonal head screws
 * ISO 4032 / DIN 934 - hexagonal nuts
 * ISO 4762 / DIN 921 - Allen screws
 *
 * License: CC BY-NC-SA 4.0
 *          Creative Commons 4.0 Attribution — Noncommercial — Share Alike
 *          https://creativecommons.org/licenses/by-nc-sa/4.0/
 *
 * Author: Thomas Richter
 * Contact: mail@thomas-richter.info
 */

// order of parameters, names from DIN / ISO tables in (brackets)
// size, screwDiameter (d1), screwHeadDiameter (e), screwHeadHeight (k), allenHeadDiameter (dk), allenHeadHeight (k)
//
// note that the screwHewadDiameter is the largest dimension, NOT the wrench size.
// In DIN and ISO dimension tables, this dimension is usually designated as e.
//     ___
//    /   \
//    \___/
//    --e--
// dimensions from DIN 933 / ISO 4017 and DIN 912 / ISO 4762 (inbus / allen)
// [size, d1, e, k, inbus dk, inbus k]
screws = [
    ["M4", 4,  7.66, 2.8,  7.0, 4],
    ["M5", 5,  8.79, 3.5,  8.5, 5],
    ["M6", 6, 11.05, 4.0, 10.0, 6],
    ["M8", 8, 14.38, 5.3, 13.0, 8],
];

// order of parameters, names from DIN / ISO tables in (brackets)
// size, threadDiameter, nutDiameter (e), nutHeight (m)
// dimensions from DIN 934 / ISO 4032
nuts = [
    ["M4", 4,  7.66, 3.2],
    ["M5", 5,  8.79, 4.7],
    ["M6", 6, 11.05, 5.2],
    ["M8", 8, 14.38, 6.8]
];

// selector functions to simplify the selection of the entities
function selectFromDict(item, dict) = dict[search([item], dict)[0]];

function selectScrew(size) = selectFromDict(size, screws);

function selectNut(size) = selectFromDict(size, nuts);