

const openScadBinaryFilePath = process.env.OPENSCAD_BINARY_FILE_PATH;

const scadFilePath = process.env.SCAD_MODEL_FILE_PATH;

const publicPath = process.env.PUBLIC_PATH;
const outputPath = `${publicPath}${process.env.OUTPUT_PATH}`;

const scadOptions = `--export-format binstl --backend manifold`;
//const scadOptions = `--export-format png --backend manifold`;

const customValues = {
    'SIZE': 'M8',
    'TYPE': 'hex',
    'SHAPE': 'rounded',
    'ARMS': 5,
    'DIAMETER_RATIO': 7,
    'QUALITY': 360,
};

const getCustomOptions = (optionsObject) => {
    return Object.entries(optionsObject).map(([key, value]) =>
        ` --D ${key}=${!isNaN(Number(value)) ? value : (`\\"${value}\\"`)}`
    ).join('');
};

// returns the options that can be modified in the customizer
const getOptionsFromScad = () => {
    // TODO: parse the actual model file
    return [{
            name: 'SIZE',
            type: 'string',
            range: ['M3', 'M4', 'M5', 'M6', 'M8', 'M10', 'M12', 'M14', 'M16']
        }, {
            name: 'TYPE',
            type: 'string',
            range: ['hex', 'allen', 'inbus', 'hexnohub', 'lockhub']
        }, {
            name: 'SHAPE',
            type: 'string',
            range: ['rounded', 'flat']
        }, {
            name: 'ARMS',
            type: 'integer',
            range: [3, 101]
        }, {
            name: 'DIAMETER_RATIO',
            type: 'number',
            range: [5, 10]
        }, {
            name: 'QUALITY',
            type: 'integer',
            range: [24, 720]
        }];
};

const validateOptionType = (option, optionDefinition) => {
    switch (optionDefinition.type) {
        case 'string':
            if (typeof option.value !== 'string') {
                return false;
            }
            break;
        case 'integer':
            const numValue = Number(option.value);
            if (isNaN(numValue)) {
                return false;
            }
            if (numValue !== parseInt(numValue)) {
                return false;
            }
            break;
        case 'number' :
            if (isNaN(Number(option.value))) {
                return false;
            }
            break;
        default: 
            return false;
            break;
    }

    return true;
};

const validateOptionRange = (option, optionDefinition) => {
    switch (optionDefinition.type) {
        case 'string':
            // find the value in the range
            // TODO: check if strings must be sanitized
            // Can string parameters be harmful when passed into OpenSCAD variables?
            if (optionDefinition.range.length !== 0 &&
                optionDefinition.range.indexOf(option.value) === -1) {
                return false;
            }
            break;
        case 'integer':
        case 'number':
            // check the range
            if (option.value < optionDefinition.range[0] ||
                option.value > optionDefinition.range[1]) {
                return false;
            }
            break;
        default: 
            return false;
            break;
    }

    return true;
};

// validates one option object
// returns true if it meets the requirements, false otherwise
const validateOption = (option, allowedOptions) => {
    // check the name
    const optionDefinition = allowedOptions.find(element => element.name === option.name);
    if (undefined === optionDefinition) {
        return `Option ${option.name} is not a valid option`;
    }

    // check the type
    if (!validateOptionType(option, optionDefinition)) {
        return `Option ${option.name} must be of type ${optionDefinition.type}`;
    }

    // check the range
    if (!validateOptionRange(option, optionDefinition)) {
        return `Option ${option.name} must be in the range [${optionDefinition.range.toString()}]`;
    }

    return '';
};

// clean the options object
// returns the object reduced to the elements that meet the requiements
const cleanOptions = (query) => {
    const optionDefinitions = getOptionsFromScad();

    let errors = [];
    let cleanedOptions = {};
    // TODO actually clean it
    
    // put the query params into an array [{name: ..., value: ...}, {...}, ...]
    const options = Object.entries(query).map(([key, value]) => ({
        name: key,
        value: value
    }));

    for (const option of options) {
        const validationResult = validateOption(option, optionDefinitions);
        if ('' === validationResult) {
            cleanedOptions[option.name] = option.value;
        } else {
            errors.push(validationResult);
        }
    }

    cleanedOptions.errors = errors;

    return cleanedOptions;
};

const renderModel = (customOptions) => {
// execute shell script: https://stackoverflow.com/a/20643568
    
    const command = `${openScadBinaryFilePath} ${scadFilePath} ${scadOptions} ${customOptions}`;

    const { execSync } = require('child_process');
    execSync(command, (err, stdout, stderr) => {
        if (err) {
            // node couldn't execute the command
            return;
        }

        // the *entire* stdout and stderr (buffered)
        console.log(`stdout: ${stdout}`);
        console.log(`stderr: ${stderr}`);
    });
};


const express = require('express');
const app = express();
const port = 3000;

app.use(express.static(publicPath));

app.get('/api/v1/mesh', (req, res) => {
    console.log(req.query);

    const q = cleanOptions(req.query);

    if (q.errors.length !== 0) {
        res.send(`Errors: ${q.errors}`);
        return;
    }

    // delete the empty errors property
    delete q.errors;

    // calculate result code
    const crypto = require('crypto');
    const uuid = crypto.randomUUID();

    const outputFile = `${uuid}.stl`;
    //const outputFile = `${uuid}.png`;

    const customOptions = getCustomOptions(q) + ` --o ${outputPath}${outputFile}`;

    // TODO: is executed asynchronously
    renderModel(customOptions);

    res.send({url: `/${process.env.OUTPUT_PATH}${outputFile}`});
});

app.listen(port, () => {
  console.log(`Example app listening on port ${port}`);
});

/*
{
    url: "output/cbe135d6-a5e2-4d4c-93cb-072e7af9902d.png"
}
/**/