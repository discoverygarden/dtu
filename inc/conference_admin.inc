<?php

function dtu_render_conference_admin() {
  $output = '';

  $pid = arg(2);
  if ($pid && valid_pid($pid)) {
    module_load_include('inc', 'fedora_repository', 'api/fedora_item');
    $item = new Fedora_Item($pid);
    $rels = $item->get_relationships('contributionCollection');
    if (!empty($rels)) {
      $output .= l(t('Administer Contributions'), 'admin/conference/' . $rels[0]['object'] . '/contributions');
    }
  }
  return $output;
}
