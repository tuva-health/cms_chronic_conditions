#!/usr/bin/env python3

import re
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
EXPECTED_ASSET_SLUG = "cms-chronic-conditions"
EXPECTED_VERSION_CALL = (
    "cms_chronic_conditions.get_cms_chronic_conditions_package_version()"
)
VERSION_MACRO = (
    ROOT / "macros" / "get_cms_chronic_conditions_package_version.sql"
)


class PackageContractTest(unittest.TestCase):
    def test_project_and_macro_versions_match(self):
        project_text = (ROOT / "dbt_project.yml").read_text()
        macro_text = VERSION_MACRO.read_text()

        project_version = re.search(
            r"(?m)^version:\s*['\"]([^'\"]+)['\"]\s*$", project_text
        )
        macro_version = re.search(
            r"return\(\s*['\"]([^'\"]+)['\"]\s*\)", macro_text
        )

        self.assertIsNotNone(project_version)
        self.assertIsNotNone(macro_version)
        self.assertEqual(project_version.group(1), macro_version.group(1))
        self.assertIn(
            'require-dbt-version: ">=1.10.5,<2.0.0"', project_text
        )

    def test_declared_dependencies(self):
        packages_text = (ROOT / "packages.yml").read_text()

        # dbt_utils is a compatible-range dependency, not an exact pin, so
        # consumers can resolve one dbt_utils across the whole Tuva fleet.
        self.assertIn('version: [">=1.2.0", "<2.0.0"]', packages_text)

        # the_tuva_project (tuva-core) must stay declared: dbt_project.yml calls
        # the_tuva_project.load_package_seed and the models ref core__* models.
        self.assertIn(
            'git: "https://github.com/tuva-health/tuva-core.git"',
            packages_text,
        )

    def test_data_asset_slug_is_stable(self):
        catalog_text = (ROOT / "data_assets.yml").read_text()
        package_slug = re.search(
            r"(?m)^package:\s*(\S+)\s*$", catalog_text
        )

        self.assertIsNotNone(package_slug)
        self.assertEqual(package_slug.group(1), EXPECTED_ASSET_SLUG)

    def test_every_asset_loader_uses_the_package_version_macro(self):
        project_text = (ROOT / "dbt_project.yml").read_text()
        catalog_text = (ROOT / "data_assets.yml").read_text()
        loader_calls = re.findall(
            r"load_package_seed\(\s*'([^']+)'\s*,\s*([^,]+?)\s*,\s*'([^']+)'\s*\)",
            project_text,
            re.DOTALL,
        )
        catalog_paths = re.findall(r"(?m)^    path:\s*(\S+)\s*$", catalog_text)

        self.assertEqual(sorted(call[2] for call in loader_calls), sorted(catalog_paths))
        for package_slug, version_call, _ in loader_calls:
            self.assertEqual(package_slug, EXPECTED_ASSET_SLUG)
            self.assertEqual(version_call.strip(), EXPECTED_VERSION_CALL)

    def test_release_workflow_runs_package_contract(self):
        workflow_text = (
            ROOT / ".github" / "workflows" / "create-release.yml"
        ).read_text()
        checkout_position = workflow_text.index("uses: actions/checkout@")
        contract_position = workflow_text.index(
            "run: python3 scripts/test_package_contract.py"
        )
        version_check_position = workflow_text.index("- name: Check version change")

        self.assertLess(checkout_position, contract_position)
        self.assertLess(contract_position, version_check_position)


if __name__ == "__main__":
    unittest.main()
