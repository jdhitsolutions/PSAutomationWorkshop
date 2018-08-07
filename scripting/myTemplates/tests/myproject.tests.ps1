
$template = "$psscriptroot/../myProject/plastermanifest.xml"

[xml]$xml = Get-Content -Path $template
$manifest = $xml.plastermanifest
Describe "myProject Manifest" {
  It "Should pass Test-PlasterManifest" {
      {Test-PlasterManifest -Path $template} | Should Not Throw
  }
  It "Should be a Project template" {
      $manifest.templatetype | Should be "Project"
  }
  Context "Testing Parameters" {
  $params = $manifest.parameters.parameter

  $prompts = "ModuleName","Version","Description","PSVersion","Editor"
  foreach ($item in $prompts) {
      It "Should prompt for $item" {
          $params.name | Should Contain $item
      }
  }

  It "Should have a default module version of 0.1.0" {
     $node= $manifest.Parameters.SelectNodes("*[@name='Version']")
     $node.default | Should be "0.1.0"
  }

  It "Should default the author name to 'User-Fullname' " {
    $node= $manifest.Parameters.SelectNodes("*[@name='ModuleAuthor']")
    $node.type | Should be "user-fullname"
  }

  It "Should include an editor choice of VSCode" {
    $node= $manifest.Parameters.SelectNodes("*[@name='Editor']")
    $node.choice.value | Should contain "VSCode"
  }
  } #parameters context

  context Content {
      $content = $manifest.content

      It "Should create a module manifest" {
          $content.newModuleManifest | Should not be $null
      }

      It "Should create a docs folder" {
          $content.file.destination | Should contain "docs"
      }

      it "Should create an en-us folder" {
          $content.file.destination | Should contain "en-us"
      }

      it "Should copy a psm1 file from source" {
        $content.file.source | Should contain 'module.psm1'
      }

      $temps = "changelog.txt","README.md","license.txt"
      foreach ($file in $temps) {
          It "Should create $file from a template file" {
              $content.templateFile.source | Should contain $file
              $content.templateFile.destination | Should contain $file

          }
      }
      It "Should create a Pester test" {
        $content.SelectNodes("//*[contains(@source,'test')]") | should not be null
      }


  It "Should require the Pester module" {
      #$content.requireModule.SelectNodes("*[@name='Pester']") | should not be null
      $content.requireModule.name | should contain "Pester"
  }
} #content context
} 
