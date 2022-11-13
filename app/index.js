// Octokit.js
// https://github.com/octokit/core.js#readme

require('dotenv').config()

const { Octokit } = require("octokit");

const octokit = new Octokit({
	auth: process.env.PERSONAL_TOKEN
})

const keep = process.env.VERSION_KEEP;

async function main() {
	await get_tags();
	if (process.env.REPO_TYPE != "User") {
		await get_image_org_version();
	} else {
		await get_image_version();
	}
}

async function get_tags() {
	try {
		const response = await octokit.request('GET /repos/{owner}/{repo}/git/refs/tags', {
			owner: process.env.REPO_OWNER,
			repo: process.env.REPO_NAME
		})
		response.data.reverse().forEach(delete_tags);
	} catch (error) {
		console.log(error.response.data.message);
	}
}

async function get_image_version() {
	try {
		const response = await octokit.request(
			'GET /users/{username}/packages/{package_type}/{package_name}/versions',
			{
				package_type: 'container',
				package_name: process.env.REPO_NAME,
				username: process.env.REPO_OWNER,
			}
		)
		response.data.forEach(delete_image_version);
	} catch (error) {
		console.log(error.response.data.message);
	}
}

async function get_image_org_version() {
	try {
		const response = await octokit.request(
			'GET /orgs/{org}/packages/{package_type}/{package_name}/versions',
			{
				package_type: 'container',
				package_name: process.env.REPO_NAME,
				org: process.env.REPO_OWNER,
				state: 'active'
			}
		);
		response.data.forEach(delete_image_org_version);
	} catch (error) {
		console.log(error.response.data.message);
	}
}

async function delete_tags(item, index) {
	try {
		var refs = item.ref.replace("refs/", "");
		if (index > keep) {
			const response = await octokit.request('DELETE /repos/{owner}/{repo}/git/refs/{ref}', {
				owner: process.env.REPO_OWNER,
				repo: process.env.REPO_NAME,
				ref: refs
			})
			console.log(index + " " + refs + " deleted with return code: " + response.status);
		} else {
			console.log(index + " " + refs + " skipped");
		}
	} catch (error) {
		console.log(error.response.data)
	}
}

async function delete_image_version(item, index) {
	try {
		if (index > keep) {
			const response = await octokit.request(
				'DELETE /users/{username}/packages/{package_type}/{package_name}/versions/{package_version_id}',
				{
					package_type: 'container',
					package_name: process.env.REPO_NAME,
					username: process.env.REPO_OWNER,
					package_version_id: item.id
				}
			)
			console.log(index + " " + item.metadata.package_type + " " + item.metadata.container.tags[0] + " deleted with return code: " + response.status);
		} else {
			console.log(index + " " + item.metadata.package_type + " " + item.metadata.container.tags[0] + " skipped");
		}
	} catch (error) {
		console.log(error)
	}
}

async function delete_image_org_version(item, index) {
	try {
		if (index > keep) {
			const response = await octokit.request('DELETE /orgs/{org}/packages/{package_type}/{package_name}/versions/{package_version_id}', {
				package_type: 'container',
				package_name: process.env.REPO_NAME,
				org: process.env.REPO_OWNER,
				package_version_id: item.id
			})
			console.log(index + " " + item.metadata.package_type + " " + item.metadata.container.tags[0] + " deleted with return code: " + response.status);
		} else {
			console.log(index + " " + item.metadata.package_type + " " + item.metadata.container.tags[0] + " skipped");
		}
	} catch (error) {
		console.log(error)
	}
}

main();