"""Regression checks for patch selection and large-file feature visibility."""
import pathlib
import subprocess
import tempfile
import unittest

SCRIPT = pathlib.Path(__file__).resolve().parents[1] / "diy-part1.sh"


class BinutilsPatchTest(unittest.TestCase):
    def test_versioned_patches_enable_feature_before_copyright_comment(self):
        with tempfile.TemporaryDirectory() as directory:
            root = pathlib.Path(directory)
            for version in ("2.40", "2.42", "2.43.1"):
                (root / "toolchain/binutils/patches" / version).mkdir(parents=True)
            subprocess.run(["bash", str(SCRIPT)], cwd=root, check=True)
            for version in ("2.40", "2.42", "2.43.1"):
                with self.subTest(version=version):
                    source_root = root / version
                    (source_root / "binutils").mkdir(parents=True)
                    source = source_root / "binutils/readelf.c"
                    source.write_text(
                        "/* readelf.c -- display contents of an ELF format file\n"
                        "   Copyright notice. */\n"
                        "#ifndef _LARGEFILE64_SOURCE\n"
                        '#error "large-file API was not enabled before headers"\n'
                        "#endif\nint main(void) { return 0; }\n"
                    )
                    patch = root / "toolchain/binutils/patches" / version / "100-largefile64-readelf.patch"
                    original_patch = patch.read_bytes()
                    subprocess.run(["patch", "-p1", "--batch", "-i", str(patch)], cwd=source_root, check=True)
                    subprocess.run(["cc", "-Werror", "-fsyntax-only", str(source)], check=True)
                    subprocess.run(["bash", str(SCRIPT)], cwd=root, check=True)
                    self.assertEqual(patch.read_bytes(), original_patch)
            self.assertFalse((root / "toolchain/binutils/patches/100-largefile64-readelf.patch").exists())

    def test_missing_upstream_layout_fails_clearly(self):
        with tempfile.TemporaryDirectory() as directory:
            result = subprocess.run(["bash", str(SCRIPT)], cwd=directory, capture_output=True, text=True)
            self.assertNotEqual(result.returncode, 0)
            self.assertIn("No versioned binutils patch directories", result.stderr)


if __name__ == "__main__":
    unittest.main()
