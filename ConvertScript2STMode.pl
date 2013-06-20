#!perl -w
use strict;
use Encode;
use constant DEBUG => 1;
use 5.010;

=abc
README
把7.7的eScript,通过解析，使之成为ST Engine的强类型声明
var bo:BusObject = …
var bc:BusComp = …
var ar:Array = …
var ps:PropertySet = …
var bs: Service = 

注意点.
	1、解析出那些对象需要替换
	2、只解析标准的写法,即 var variable = [TheApplication()|TheApp].[GetBusObject|NewPropertySet|GetService](); 
	                       var variable = BO.GetBusComp();

针对变量在function前面声明的情况，需要两个步骤来完成:
STEP 1:
BS_NAME,FUNCTION_NAME,VARIABLE_NAME,TYPE;

STEP 2:
根据上面的清单,找到对应的变量,替换其声明方式:
eg:var bo,bc --> var bo:BusObject,bc:BusComp;

全局范围的变量不做考虑

错误检查:
1、是否需要变量存在重复赋值的情况

ivan yao, HC ( yhf@zjhcsoft.com )
2013/06/19

=cut

#my $dir = "G:\\M\\";

if ($#ARGV != 0 ) {
    printf "Please specify the input FILE_DIR include BS.sif,eg:C:\\sif";
    exit ;
}

my $dir = $ARGV[0] ;


opendir (LSTDIR, "$dir") or die "Cannot open directory \"$dir\": ($!).\n";
my @files = grep(/\.sif/,readdir(LSTDIR));
closedir (LSTDIR);

=abc
my @objects = (	    
'\s*=\s*(TheApplication\(\)|TheApp)\.(GetBusObject|NewPropertySet|GetService)\s*\(',
'\s*=\s*[\w].*\.GetBusComp\s*\('
);
=cut
my $func_name;
my @lines;
my @variables;

open (CSV,">>","D:\\out_log.csv") or die "Cannot create file \"D\\out_log.csv\": ($!).\n";

foreach my $file (@files) {

open (FILE,"<", "$dir\\$file") or die "Cannot open file \"$dir\\$file\": ($!).\n";
open OUTPUTFILE,">$dir\\convert\\$file"."OK.sif" or die "Cannot open file \"$dir\\convert\\$file\": ($!).\n";

my $bPrintedLine = 0 ;

while (<FILE>) {

	chomp;

	my $line = $_;

	if(/^[\t\s]*<BUSINESS_SERVICE_SERVER_SCRIPT$/){
        $bPrintedLine = 1;
        undef @variables;
    }

    if(/^[\t\s]*<\/BUSINESS_SERVICE_SERVER_SCRIPT>$/){
    	$bPrintedLine = 0;
    }

    if(/^[\t\s]*NAME=/ && $bPrintedLine == 1){
        $func_name = (split(/\"/,$_))[1];
    }


	my $tmp = '\s*=\s*(TheApplication\(\)|TheApp)\.(GetBusObject|NewPropertySet|GetService)\s*\(';

	if($line =~ m/$tmp/ && $line =~ m/^[\s\t]*var[\W]/){

		$line =~ s/$tmp.*//;
		$line =~ s/^[\s\t]*//;
        $line =~ s/var[\s\t]*//;
		
		if($line !~ /\W/){
			my $icount = 0;
			if(/\.GetBusObject/){
				substr($_, index($_, "$line"), length($line)) = "$line:BusObject";
				$icount++;
			}

			if(/\.GetService/){
				substr($_, index($_, "$line"), length($line)) = "$line:Service";
				$icount++;
			}

			if(/\.NewPropertySet/){
				substr($_, index($_, "$line"), length($line)) = "$line:PropertySet";
				$icount++;
			}

			print CSV "$file,$func_name,$icount,".trim($line).",$_\n";
		}
	}

	if($line =~ m/$tmp/ && $line !~ m/^[\s\t]*var[\W]/){

		$line =~ s/$tmp.*//;
		$line =~ s/^[\s\t]*//;
		
		if($line !~ /\W/){
			if(/\.GetBusObject/){
				push (@variables, "$line:BusObject");
			}

			if(/\.GetService/){
				push (@variables, "$line:Service");
			}

			if(/\.NewPropertySet/){
				push (@variables, "$line:PropertySet");
			}
		}
	}

	if($line =~ m/\.GetBusComp[\s\t]*\(/ && $line =~ m/^[\s\t]*var[\W]/){
		my $icount = 0;
        $line =~ s/var[\s\t]*//;

        my @tmp = split(/\(&quot;|&quot;\)|[=.]/,$line);
=abc       
        if((!defined($tmp[3]) || $tmp[3] =~ /^\s+$/)){
            print "SKipping : $tmp[0],$tmp[1],$tmp[2]\n";
            goto PRINT2LINE;
        }
=cut
        #$tmp[2] == 'GetBusComp'
        #$tmp[0] !~ /\W/
        my $bc_var = trim($tmp[0]) ;
        if($bc_var !~ /\W/ && (trim($tmp[2]) eq 'GetBusComp' || $tmp[2] =~ m/^GetBusComp[\s\t]*\(/)){
       		substr($_, index($_, "$bc_var"), length($bc_var)) = "$bc_var:BusComp";
       		$icount++;
       	}

       	print "ignore : <-$bc_var->$tmp[2]<-\n" if(!$icount);
       	print CSV "$file,$func_name,$icount,".$bc_var.",$_\n";
	}


	if($line =~ m/\.GetBusComp[\s\t]*\(/ && $line !~ m/^[\s\t]*var[\W]/){

		$line =~ s/^[\s\t]*//;
        my @tmp = split(/\(&quot;|&quot;\)|[=.]/,$line);

        my $bc_var = trim($tmp[0]) ;
        if($bc_var !~ /\W/ && (trim($tmp[2]) eq 'GetBusComp' || $tmp[2] =~ m/^GetBusComp[\s\t]*\(/)){
       		push (@variables , "$bc_var:BusComp");
       	}
	}

	
#	PRINT2LINE:

	if ($bPrintedLine == 0 ) {

		while(@lines){

			my $t = shift @lines;
			chomp $t;
			#only for start with 'var'
			if($t =~ m/^[\s\t]*var[\W]/){
				my $tmp_line = $t;
				$tmp_line =~ s/[\s\t]*var[\s\t]*//;
				my @vars = split(/,|;/,$tmp_line);
				foreach(@vars){
					#把var a,b;
					if($_ && $_ !~ /\W/){

						foreach my $var (@variables){

							my @tmp_var = split(/:/,$var);
							if($tmp_var[0] eq $_){
								#print $var."\n";
								if($t =~ /$_,/){
									substr($t, index($t, "$_,"), length("$_,")) = "$var,";
								}
								if($t =~ /$_;/){
									substr($t, index($t, "$_;"), length("$_;")) = "$var;";
								}
								print CSV "$file,$func_name,x,".$_.",$t\n";
							}
						}
					}
				}
			}
			print OUTPUTFILE "$t\n" ;
		}

		undef @variables if(@variables);

        print OUTPUTFILE "$_\n" ;

    }else{

    	push(@lines,"$_\n");

    }
	
};


close (OUTPUTFILE);
close (FILE);

};#END foreach

close (CSV);
=abc
another promo method;
#SUBS
=cut

sub trim {

    my $tmp = shift;
    $tmp =~ s/^\s+|\s+$//g;
    return $tmp;
}

__END__