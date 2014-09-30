targetvar1=${1:-filename}
targetvar2=${2:-basename}

_ deriving \
  -A "$targetvar2" "$targetvar1" 's{^(.*/)?}{}' \
  -A date_y "$targetvar1" 's{^.*arXiv_([a-z]+)_(\d{2})(\d{2})_(\d{3}).*}{
    ( ($2 < 91) ? $2 + 2000 : 1900 + $2)
  }ex' \
  -A date_m "$targetvar1" 's{^.*arXiv_([a-z]+)_(\d{2})(\d{2})_(\d{3}).*}{$3}ex' \
  -A date_ym "$targetvar1" 's{^.*arXiv_([a-z]+)_(\d{2})(\d{2})_(\d{3}).*}{
    ( ($2 < 91) ? $2 + 2000 : 1900 + $2) . "-$3"
  }ex' \
  -A manifest_type "$targetvar1" 's{^.*arXiv_([a-z]+)_(\d{4})_(\d{3}).*}{$1}' \
  -A uri "$targetvar1" 's{^.*(arXiv_([a-z]+)_(\d{2})(\d{2})_(\d{3}).*)}{
    "s3://arxiv/$2/$1"
}ex' \
  -v local_path '"s3/arxiv/$h->{manifest_type}/$h->{date_y}/$h->{date_m}/$h->{basename}"' \
  -A block_num "$targetvar1" 's{^.*arXiv_([a-z]+)_(\d{2})(\d{2})_(\d{3}).*}{$4}ex' \
